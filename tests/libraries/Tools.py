import base64

def base_64_encode(input):
    return base64.b64encode(input.encode()).decode("utf-8")

def build_authentication(schema, id, secret):
    return schema + " " + base_64_encode(id + ":" + secret)

def filter_list(list, attr, value):
    return [elem for elem in list if elem[attr] == value]
