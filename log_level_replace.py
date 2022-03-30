#pip install pyyaml
import yaml
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-l", "--log_level", default='WARNING', action='store', help="default log level to set")
parser.add_argument("--filename", help="patched config.yaml filename")
args = parser.parse_args()

# Find config filename
filename=args.filename
with open(filename) as f:
     doc = yaml.safe_load(f)

# Engine
key='level'
value=args.log_level
def replace_log_level(d):
    #https://stackoverflow.com/questions/55704719/python-replace-values-in-nested-dictionary
    for k,v in d.items():
        if k == key:
            d[k] = value
        elif type(v) is list:
            for item in v:
                if type(item) is dict:
                    replace_log_level(item)
        if type(v) is dict:
            replace_log_level(v)
# main
data_dict=doc['logging']
replace_log_level(data_dict)
doc['logging']=data_dict

with open(filename, "w") as f:
    yaml.dump(doc, f)

