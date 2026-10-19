import json,urllib.request,urllib.parse,re,os,sys
UA={'User-Agent':'METARET-research-script/1.0 (academic literature collection)'}
def get(u,raw=False,hdr=None,t=60):
    import time
    for i in range(6):
        try:
            r=urllib.request.urlopen(urllib.request.Request(u,headers=hdr or UA),timeout=t)
            b=r.read(); return b if raw else json.loads(b)
        except urllib.error.HTTPError as e:
            if e.code==429 and i<5: time.sleep(30*(i+1)); continue
            raise
def dc(doi):
    return get('https://api.datacite.org/dois/'+urllib.parse.quote(doi))['data']['attributes']
def files(doi,url):
    """return list of (name,size,downloadurl) or None"""
    d=doi.lower()
    try:
        if 'dvn' in d or 'dataverse' in (url or '') or d.startswith('10.34894') or d.startswith('10.11588/data'):
            host=urllib.parse.urlparse(url).netloc
            if 'doi.org' in host or not host: host='dataverse.harvard.edu'
            j=get(f'https://{host}/api/datasets/:persistentId/?persistentId=doi:{doi}')
            fs=j['data']['latestVersion']['files']
            return [(f['dataFile']['filename'],f['dataFile']['filesize'],f'https://{host}/api/access/datafile/{f["dataFile"]["id"]}?format=original' if f['dataFile'].get('originalFileFormat') else f'https://{host}/api/access/datafile/{f["dataFile"]["id"]}') for f in fs]
        if 'zenodo' in d:
            rid=re.search(r'zenodo\.(\d+)',d).group(1)
            j=get('https://zenodo.org/api/records/'+rid)
            return [(f['key'],f['size'],f['links']['self']) for f in j['files']]
        if '17632' in d:
            m=re.search(r'17632/([a-z0-9]+)',d).group(1)
            meta=get(f'https://data.mendeley.com/public-api/datasets/{m}')
            ver=meta['doi']['id'].rsplit('.',1)[-1] if re.search(r'\.\d+$',meta['doi']['id']) else '1'
            j=get(f'https://data.mendeley.com/public-api/datasets/{m}/files?folder_id=root&version={ver}')
            return [(f['filename'],f['content_details']['size'],f['content_details']['download_url']) for f in j]
        if 'figshare' in d:
            a=re.search(r'figshare\.(\d+)',d).group(1)
            j=get('https://api.figshare.com/v2/articles/'+a)
            return [(f['name'],f['size'],f['download_url']) for f in j['files']]
        if 'osf.io' in d:
            n=d.split('osf.io/')[1]
            j=get(f'https://api.osf.io/v2/nodes/{n}/files/osfstorage/')
            return [(f['attributes']['name'],f['attributes']['size'],f['links']['download']) for f in j['data'] if f['attributes']['kind']=='file']
        if '5061/dryad' in d:
            return 'Dryad file downloads need an authenticated API token (401); download manually in the browser'
    except Exception as e:
        return 'ERR '+str(e)[:100]
    return None
