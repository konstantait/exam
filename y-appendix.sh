#!/usr/bin/env bash

mkdir -p ./folder1/folder1-1/subfolder1-1
mkdir -p ./folder1/folder1-2/subfolder1-2
mkdir -p ./folder2/folder21
mkdir -p ./folder2/folder22/subfolder22/subsubfolder22
touch ./folder1/folder1-1/file{1..2}
touch ./folder1/folder1-1/subfolder1-1/file{1..3}
touch ./folder1/folder1-2/file{1..3}
touch ./folder1/folder1-2/subfolder1-2/file{1..2}
touch ./folder2/folder21/file{1..2}
touch ./folder2/folder22/file{1..4}
touch ./folder2/folder22/subfolder22/file{1..3}
touch ./folder2/folder22/subfolder22/subsubfolder22/file{1..3}

# folder1
# ├── folder1-1
# │   ├── file1
# │   ├── file2
# │   └── subfolder1-1
# │       ├── file1
# │       ├── file2
# │       └── file3
# └── folder1-2
#     ├── file1
#     ├── file2
#     ├── file3
#     └── subfolder1-2
#         ├── file1
#         └── file2
# folder2
# ├── folder21
# │   ├── file1
# │   └── file2
# └── folder22
#     ├── file1
#     ├── file2
#     ├── file3
#     ├── file4
#     └── subfolder22
#         ├── file1
#         ├── file2
#         ├── file3
#         └── subsubfolder22
#             ├── file1
#             ├── file2
#             └── file3

pstree -up > process-list.txt

dpkg --get-selections | grep -v deinstall > package-list.txt