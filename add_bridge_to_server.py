#pip install pyyaml
import yaml
import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument("-n", "--name", help="appended registration yaml")
args = parser.parse_args()


name = '/etc/matrix-synapse/conf.d/apps.yaml'
filename = name
with open(filename) as f:
     doc = yaml.safe_load(f)

try:
	apps=doc['app_service_config_files']
	apps.append(args.name)
except (KeyError, TypeError):
	apps=[args.name]

try:
	doc['app_service_config_files']=apps
except TypeError:
	# yaml file was blank
	doc = {'app_service_config_files':args.name}

yaml.dump(doc,sys.stdout)
