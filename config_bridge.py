#pip install pyyaml
import yaml
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-n", "--name", help="server_name")
parser.add_argument("-p", "--password", help="postgres password")
parser.add_argument("-i", "--id", help="telegram app id")
parser.add_argument("--hash", help="telegram app hash")
parser.add_argument("--bridge", help="Bridge name", default='telegram', action='store')
args = parser.parse_args()


filename = f'/nas/bridge_{args.bridge}/config.yaml'
with open(filename) as f:
     doc = yaml.safe_load(f)

# configs:
doc['homeserver']['address']=f'https://{args.name}'
doc['homeserver']['domain']=args.name

# database
doc['appservice']['database']=f'postgres://{args.bridge}_user:{args.password}@127.0.0.1/{args.bridge}'

# config
doc[args.bridge]['api_id']=int(args.id)
doc[args.bridge]['api_hash']=args.hash

# bridge
perm={}
perm['*']='relaybot'
perm['@idanre1:%s' % args.name]='puppeting'
doc['bridge']['permissions']=perm

with open(filename, "w") as f:
    yaml.dump(doc, f)
