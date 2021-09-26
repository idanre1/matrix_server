#pip install pyyaml
import yaml
import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument("-n", "--name", help="appended registration yaml")
args = parser.parse_args()


name = '/etc/matrix-synapse/homeserver.yaml'
filename = name
with open(filename) as f:
     doc = yaml.safe_load(f)

try:
	apps=doc['app_service_config_files']
	apps.append(args.name)
except KeyError:
	apps=[args.name]

doc['app_service_config_files']=apps

yaml.dump(doc,sys.stdout)
