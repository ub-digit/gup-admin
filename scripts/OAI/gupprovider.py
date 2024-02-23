from oai_repo import DataInterface, Identify, MetadataFormat, RecordHeader
from elasticsearch import Elasticsearch
import oai
import lxml
import lxml.etree as ET

class GUPProvider(DataInterface):
    def __init__(self):
        self.index = 'publications'
        self.es = Elasticsearch(hosts=[{'host': 'localhost', 'port': 9200, 'scheme': 'http'}])
        self.limit = 20
        self.provider = oai.OAIProvider()

    def get_identify(self) -> Identify:
        ident = Identify()
        ident.repository_name = 'GUP'
        ident.base_url = 'https://gup-staging.ub.gu.se'
        ident.granularity = 'YYYY-MM-DDThh:mm:ssZ'
        ident.admin_email = ['user@example.org']
        ident.deleted_record = 'no'
        ident.earliest_datestamp = '1950-10-01T00:00:00Z'
        return ident

    def get_record_metadata(self, identifier: str, metadata_prefix: str) -> lxml.etree._Element:
        # Return the metadata field
        metadata = ET.fromstring(self.provider.get_oai_data(identifier))
        # Strip the root element
        return metadata
    
    def get_record_header(self, identifier: str) -> RecordHeader:
        # Get the record from the index
        # Return the header field in parsed XML
        return self.build_recordheader(identifier)
    
    def get_record_abouts(self, identifier: str) -> list:
        return []

    def is_valid_identifier(self, identifier: str) -> bool:
        # Check if the record exists in the index
        res = self.es.exists(index=self.index, id=identifier)
        return res
    
    def get_metadata_formats(self, identifier = None) -> list:
        formats = ['oai_dc', 'mods']
        # Build metadata format object for each element
        return [self.build_metadata_format_object(format) for format in formats]

    def list_identifiers(self, metadata_prefix: str, from_date: str, until_date: str, set=None, cursor = 0) -> tuple:
        # Fetch the records from the index, 
        # filter datestamp by from_date and until_date if provided
        # ignore set
        if from_date is None and until_date is None:
            results = self.get_records_from_index(set, cursor)
        elif from_date is None:
            results = self.get_records_from_index_until_open(until_date, set, cursor)
        elif until_date is None:
            results = self.get_records_from_index_from_open(from_date, set, cursor)
        else:
            results = self.get_records_from_index_closed(from_date, until_date, set, cursor)

        list_of_identifiers = []
        for result in results[0]:
            list_of_identifiers.append(result['_source']['id'])

        total_size = results[1]
        return (list_of_identifiers, total_size, None)

    def get_records_from_index_from_open(self, until_date: str, set=None, cursor = 0) -> tuple:
        # Fetch the records from the index, 
        # filter datestamp by until_date if provided
        # ignore set
        results = self.es.search(index=self.index, body={
            'query': {
                'range': {
                    'updated_at': {
                        'lte': until_date
                    }
                }
            },
            'from': cursor,
            'size': self.limit
        })

        # Return tuple of records and total number of records
        return (results['hits']['hits'], results['hits']['total']['value'])

    def get_records_from_index_until_open(self, from_date: str, set=None, cursor = 0) -> tuple:
        # Fetch the records from the index, 
        # filter datestamp by from_date if provided
        # ignore set
        results = self.es.search(index=self.index, body={
            'query': {
                'range': {
                    'updated_at': {
                        'gte': from_date
                    }
                }
            },
            'from': cursor,
            'size': self.limit
        })

        # Return tuple of records and total number of records
        return (results['hits']['hits'], results['hits']['total']['value'])
    
    def get_records_from_index_closed(self, from_date: str, until_date: str, set=None, cursor = 0) -> tuple:
        # Fetch the records from the index, 
        # filter datestamp by from_date and until_date if provided
        # ignore set
        results = self.es.search(index=self.index, body={
            'query': {
                'range': {
                    'updated_at': {
                        'gte': from_date,
                        'lte': until_date
                    }
                }
            },
            'from': cursor,
            'size': self.limit
        })

        # Return tuple of records and total number of records
        return (results['hits']['hits'], results['hits']['total']['value'])

    def get_records_from_index(self, set=None, cursor = 0) -> tuple:
        # Fetch the records from the index, 
        # Get all records
        results = self.es.search(index=self.index, body={
            'query': {
                'match_all': {}
            },
            'from': cursor,
            'size': self.limit
        })

        # Return tuple of records and total number of records
        return (results['hits']['hits'], results['hits']['total']['value'])

    def build_metadata_format_object(self, metadata_prefix: str) -> str:
        if metadata_prefix == 'oai_dc':
            return MetadataFormat(
                "oai_dc",
                "http://www.openarchives.org/OAI/2.0/oai_dc.xsd",
                "http://www.openarchives.org/OAI/2.0/oai_dc/"
            )
        elif metadata_prefix == 'mods':
            return MetadataFormat(
                "mods",
                "http://www.loc.gov/standards/mods/v3/mods-3-7.xsd",
                "http://www.loc.gov/mods/v3"
            )

    def build_recordheader(self, identifier: str) -> RecordHeader:
        # Get the record from the index
        res = self.es.get(index=self.index, id=identifier)
        # Build a recordheader object
        header = RecordHeader()
        header.identifier = identifier
        header.datestamp = res['_source']['updated_at']
        header.deleted = False
        return header