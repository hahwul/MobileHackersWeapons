# Contribute
## Fork and Build Contribute tools
First, fork this repository 
Second, Clone forked repo and compile `add-tool` and `distribute-readme` using `make` command:
```
$ git clone https://github.com/{your-id}/MobileHackersWeaponse
$ cd MobileHackersWeaponse
```

```bash
$ make contribute
```

## Add new tool
First, your tool append `data.json` using `add-tool`

Usage
```
./add-tool
Usage of ./add-tool:
  -isFirst
    	if you add new type, it use
  -url string
    	any url
```

E.g
```
$ ./add-tool -url https://github.com/blahblah/blahblah
Successfully Opened type.lst
[0] All
[1] iOS
[2] Android
[+] What is type?
1
iOS
[+] What is method(e.g Log, Proxy, Scanner, Etc..)?
Scanner
Successfully Opened data.json
```
## Distruibute (only for me)
### Distribute to common tools
```
$ ./distribute-readme
=> show new README file
```

### Distribute to Another directory
```
$ ../distribute-readme
=> show new README file in Burp Suite or ZAP Extensions
```
