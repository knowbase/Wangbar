#!/usr/bin/env python3
import os
import sys
import yaml
import shutil
import subprocess
import tempfile

def run(cmd):
    print('+ ' + ' '.join(cmd))
    subprocess.check_call(cmd)

def main():
    meta = '.pkgmeta'
    if not os.path.exists(meta):
        print('.pkgmeta not found in repo root', file=sys.stderr)
        sys.exit(1)
    with open(meta, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f) or {}
    externals = data.get('externals', {})
    if not externals:
        print('No externals found in .pkgmeta')
        return
    for dest, info in externals.items():
        url = info.get('url') if isinstance(info, dict) else info
        if not url:
            print(f'No url for {dest}, skipping')
            continue
        dest_path = os.path.normpath(dest)
        print(f'Vendoring {dest_path} <- {url}')
        # Remove existing folder to ensure clean export
        if os.path.exists(dest_path):
            shutil.rmtree(dest_path)
        parent = os.path.dirname(dest_path)
        if parent and not os.path.exists(parent):
            os.makedirs(parent, exist_ok=True)
        try:
            if 'repos.wowace.com' in url or '/trunk' in url:
                run(['svn', 'export', '--force', url, dest_path])
            elif 'github.com' in url:
                tmp = tempfile.mkdtemp()
                run(['git', 'clone', '--depth', '1', url, tmp])
                # move contents (excluding .git) into dest_path
                os.makedirs(dest_path, exist_ok=True)
                for entry in os.listdir(tmp):
                    if entry == '.git':
                        continue
                    s = os.path.join(tmp, entry)
                    d = os.path.join(dest_path, entry)
                    shutil.move(s, d)
                shutil.rmtree(tmp)
            else:
                # fallback to git clone
                run(['git', 'clone', '--depth', '1', url, dest_path])
                gitdir = os.path.join(dest_path, '.git')
                if os.path.isdir(gitdir):
                    shutil.rmtree(gitdir)
        except subprocess.CalledProcessError as e:
            print(f'Error fetching {url}: {e}', file=sys.stderr)

if __name__ == '__main__':
    main()
