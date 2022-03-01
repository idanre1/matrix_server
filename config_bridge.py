#pip install pyyaml
import yaml
import argparse
from random import randint

parser = argparse.ArgumentParser()
parser.add_argument("-n", "--name", help="server_name")
parser.add_argument("-p", "--password", help="postgres password")
parser.add_argument("-i", "--id", default='', action='store', help="telegram app id, leave blank to ignore")
parser.add_argument("--hash",     default='', action='store', help="telegram app hash, leave blank to ignore")
parser.add_argument("--bridge", help="Bridge name", default='telegram', action='store')
args = parser.parse_args()


#legacy filename = f'/nas/bridge_{args.bridge}/config.yaml'
filename = f'/opt/mautrix-{args.bridge}/config.yaml'
with open(filename) as f:
     doc = yaml.safe_load(f)

# configs:
r=rand_port
doc['homeserver']['address']=f'https://{args.name}'
doc['homeserver']['domain']=args.name
doc['appservice']['address']=f'http://localhost:{rand_port}'
doc['appservice']['hostname']='0.0.0.0'
doc['appservice']['port']=rand_port

# database
doc['appservice']['database']=f'postgres://{args.bridge}_user:{args.password}@127.0.0.1/{args.bridge}'

# config
if args.id != '':
	doc[args.bridge]['api_id']=int(args.id)
else:
	print('No api_id, ignoring...')
if args.hash != '':
	doc[args.bridge]['api_hash']=args.hash
else:
    print('No api_hash, ignoring...')

perm={}
if args.id != '':
	# API bridge
	perm['*']='relaybot'
	perm['@idanre1:%s' % args.name]='puppeting'
else:
	# password based bridge
	perm['*']='relay'
	perm['@idanre1:%s' % args.name]='admin'
doc['bridge']['permissions']=perm

with open(filename, "w") as f:
    yaml.dump(doc, f)
