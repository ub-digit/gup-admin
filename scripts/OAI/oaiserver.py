import oai_repo
from gupprovider import GUPProvider
from oai_repo.repository import OAIRepository
from oai_repo.exceptions import OAIRepoInternalException, OAIRepoExternalException
from oai_repo.response import OAIResponse
from lxml.etree import ElementTree, _ElementTree
from lxml import etree
from http import HTTPStatus
from flask import Flask, request, abort, redirect, url_for

# repo = oai_repo.OAIRepository(GUPProvider())

# response = repo.process({
#     'verb': 'GetRecord',
#     'identifier': '327784',
#     'metadataPrefix': 'mods'
# })


# print( type(response.root()) )  # lxml.etree.Element
# print( bytes(response) )        # XML byte response

def status(response: OAIResponse) -> int:
    """Get the HTTP status code to return with the given OAI response."""

    # the OAIResponse casts to boolean "False" on error
    if response:
        return HTTPStatus.OK
    else:
        error = response.xpath('/OAI-PMH/error')[0]
        if error.get('code') in {'noRecordsMatch', 'idDoesNotExist'}:
            return HTTPStatus.NOT_FOUND
        else:
            return HTTPStatus.BAD_REQUEST

def create_app(data_provider: GUPProvider) -> Flask:
    _app = Flask(
        import_name=__name__,
        static_url_path='/oai/static',
    )
    _app.logger.debug(f'Initialized the data provider: {data_provider.get_identify()}')

    @_app.route('/oai/api', methods=['GET', 'POST'])
    def endpoint():
        try:
            repo = OAIRepository(data_provider)
            # combine all possible parameters to the request
            parameters = {
                **request.args,
                **request.form,
            }

            response = repo.process(parameters)
        except OAIRepoExternalException as e:
            # An API call timed out or returned a non-200 HTTP code.
            # Log the failure and abort with server HTTP 503.
            _app.logger.error(f'Upstream error: {e}')
            abort(HTTPStatus.SERVICE_UNAVAILABLE, str(e))
        except OAIRepoInternalException as e:
            # There is a fault in how the DataInterface was implemented.
            # Log the failure and abort with server HTTP 500.
            _app.logger.error(f'Internal error: {e}')
            abort(HTTPStatus.INTERNAL_SERVER_ERROR)
        else:
            document: _ElementTree = ElementTree(response.root())
            return (
                etree.tostring(document, xml_declaration=True, encoding='UTF-8', pretty_print=True),
                status(response),
                {'Content-Type': 'application/xml'},
            )

    return _app

def app():
    return create_app(GUPProvider())

if __name__ == '__main__':
    app().run(debug=True)