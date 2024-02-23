import sys
import xml.etree.ElementTree as ET

from elasticsearch import Elasticsearch
from datetime import datetime,timezone



class OAIProvider:
    def __init__(self):
        # Initialize the OAI provider
        self.es = Elasticsearch(hosts=[{'host': 'localhost', 'port': 9200, 'scheme': 'http'}])
        self.publication_json = {}
        self.document_xml = ET.Element("dublin_core")
        
    def get_oai_data(self, pub_id):
        if self.es.exists(index="publications", id=pub_id):
            publication = self.es.get(index="publications", id=pub_id)
            self.publication_json = publication["_source"]
            # print(self.publication_json)
            return self.generate_xml_document(pub_id)
        else:
            print(f"Error loading publication: {pub_id}")

    def generate_xml_document(self, pub_id):
        root = ET.Element("OAI-PMH")
        root.set("xsi:schemaLocation", "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd")
        ET.SubElement(root, "responseDate").text = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        ET.SubElement(root, "request", metadataPrefix="mods", identifier="oai:gup.ub.gu.se/329099", verb="GetRecord").text = "https://gup.ub.gu.se/oai"
        get_record = ET.SubElement(root, "GetRecord")
        record = ET.SubElement(get_record, "record")
        header = ET.SubElement(record, "header")
        
        self.get_header(header, pub_id)
        metadata = ET.SubElement(record, "metadata")
        return ET.tostring(self.get_metadata(metadata))
        
        print(ET.tostring(root))
        return root

    def get_header(self, header, pub_id):
        # Set the identifier element in the header
        ET.SubElement(header, "identifier").text = f"oai:gup.ub.gu.se/{pub_id}"
        
        # Get the timestamp from the publication JSON
        timestamp = self.publication_json["updated_at"]
        
        # Set the datestamp element in the header
        ET.SubElement(header, "datestamp").text = timestamp  # TODO: format timestamp

    def get_metadata(self, metadata):
        mods = self.set_mods(metadata)
        ET.SubElement(mods, "recordInfo").text = "gu"
        self.get_identifiers(mods)
        self.get_title(mods)
        # Set abstract text
        ET.SubElement(mods, "abstract").text = self.publication_json["abstract"]
        self.get_subjects(mods)
        self.get_language(mods)
        self.get_authors(mods)
        self.get_notes(mods)
        return mods
        
        
    def get_identifiers(self, mods):
        identifiers = self.publication_json["publication_identifiers"]
        [self.add_identifier(mods, identifier) for identifier in identifiers]
        
    def add_identifier(self, mods, identifier_source):
        identifier = ET.SubElement(mods, "identifier")
        identifier.set("type", identifier_source["identifier_code"])
        identifier.text = identifier_source["identifier_value"]
    
    def get_title(self, mods):
        titleInfo = ET.SubElement(mods, "titleInfo")
        ET.SubElement(titleInfo, "title").text = self.publication_json["title"]
    
    def get_authors(self, mods):
        authors = self.publication_json["authors"]
        [self.add_author(mods, author) for author in authors]
        
    def add_author(self, mods, author):
        person = author['person'][0]
        
        authority = self.get_identifier_by_name(person["identifiers"], "xkonto")
        name = ET.SubElement(mods, "name")
        name.set("type", "personal")
        if authority:
            name.set("authority", "gu")
        fname = ET.SubElement(name, "namePart")
        fname.set("type", "given")
        fname.text = person["first_name"]
        lname = ET.SubElement(name, "namePart")
        lname.set("type", "family")
        lname.text = person["last_name"]
        
        if "year_of_birth" in person:
            bdate = ET.SubElement(name, "namePart")
            bdate.set("type", "date")
            bdate.text = str(person["year_of_birth"])
        
        role = ET.SubElement(name, "role")
        roleTerm = ET.SubElement(role, "roleTerm")
        roleTerm.set("type", "code")
        roleTerm.set("authority", "marcrelator")
        roleTerm.text = "aut"
        
        if authority:
            nameIdentifier = ET.SubElement(name, "nameIdentifier")
            nameIdentifier.set("type", "gu")
            nameIdentifier.text = authority
    
        affiliations = author["affiliations"]
        [self.add_affiliation(name, affiliation) for affiliation in affiliations]
            
    def add_affiliation(self, name, affiliation_source):
        affiliation = ET.SubElement(name, "affiliation")
        affiliation.text = affiliation_source["department"]
        
    def get_identifier_by_name(self, identifiers, type):
        for identifier in identifiers:
            if "type" in identifier and identifier["type"] == type:
                return identifier["value"]
        # return next((x for x in identifiers if "type" in x and x["type"] == type), None)
        return None
        
        
            
    def get_language(self, mods):
        pass
        # language = ET.SubElement(mods, "language")
        # language.text = self.publication_json["language"]
    def add_name(self, mods, name):
        pass
        # print(name)
        
    # This code is for future use
    def get_subjects(self, mods):
        pass
        # subjects = self.publication_json["subjects"]
        # [self.add_subject(mods, subject) for subject in subjects]
        
    def add_subject(self, mods, subject):
        pass
        # subject = ET.SubElement(mods, "subject")
        # subject.set("authority", subject["authority"])
        # subject.text = subject["subject"]
    
    def get_notes(self, mods):
        published_status = ET.SubElement(mods, "note")
        published_status.set("type", "publicationStatus")
        published_status.text = "Published" # self.publication_json["published"] published status is missing in json
        
        creator_count = ET.SubElement(mods, "note")
        creator_count.set("type", "creatorCount")
        creator_count.text = str(len(self.publication_json["authors"]))
    
    def set_mods(self, metadata):
        mods = ET.SubElement(metadata, "mods")
        # mods.set("version", "3.7")
        # mods.set("xsi:schemaLocation", "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd")
        return mods
if __name__ == "__main__":   
    if len(sys.argv) < 2:
        print("Please provide a publication id")
        sys.exit()
    else:
        a = OAIProvider()
        pub_id = sys.argv[1]
        print(a.get_oai_data(pub_id))


