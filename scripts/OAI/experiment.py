a = [{'type': 'xkonto', 'value': 'xskooi'}]

# b = next(x for x in a if x["type"] == "ho" )


# b = next((x for x in a if "tyspe" in x and x["tyspe"] == 'hey'), None)
# print(b)

def get_identifier_by_name(identifiers, type):
        print(identifiers)
        next((x for x in identifiers if "type" in x and x["type"] == type), None)
        
get_identifier_by_name("xkonto")