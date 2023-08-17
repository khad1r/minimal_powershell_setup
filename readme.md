<h1 align="center">
My Minimal Terminal Setup
</h1>

<h4 align="center">
<img src="https://img.shields.io/badge/Powershell-v5.1.22621.1778-blue?style=for-the-badge&logo=powershell&color=8bd5ca&logoColor=D9E0EE&labelColor=302D41" />
<img src="https://img.shields.io/badge/windows_terminal-v1.17.11461.0-blue?style=for-the-badge&logo=powershell&color=DDB6F2&logoColor=D9E0EE&labelColor=302D41" />
</h4>

## Introduction

A stylish and functional PowerShell profile that looks and feels almost as good as a Linux terminal.

advantage:

- Command Suggestion Dropdown from history by `arrow-down/arrow-up` then `enter`
- Command intelisense when hit `ctrl + space`
- Some common linux command
- terminal icon when doing `ls`, `ls | fw`, `ls | fl`
- Delete a command from History with `shift + enter`

## Install (Powershell Run As Administrator)

is recommend to run in elevated powershell:

```powershell
irm "https://raw.githubusercontent.com/khad1r/minimal_powershell_setup/main/setup.ps1" | iex
```

## Some Custom Command

| Command              | Description                      | Arg                        | Example                                |
| -------------------- | -------------------------------- | -------------------------- | -------------------------------------- |
| `sudo`               | run as admin like in Linux       | any command                | `sudo notepad example.txt`             |
| `Start-ElevatedPS{}` | Run powershell command as admin  | any powershell             | `Start-ElevatedPS{ rm file.pdf}`       |
| `Get-HotKeys`        | get powershell shortkey          | -                          | -                                      |
| `Get-PubIP`          | Get your Ip Public               | -                          | -                                      |
| `find-file`          | find file in directory           | string                     | `find-file any`,`find-file "tes any"`  |
| `unzip`              | unzip file                       | path to zip file           | `unzip file.zip`                       |
| `Compute-Hash`       | calculate hash of file or string | file/string,hash algorithm | `Compute-Hash file.zip MD5`            |
| `md5`                | hash file or string with MD5     | file/string                | `md5 file.zip`,`md5 "Hash this"`       |
| `sha1`               | hash file or string with SHA1    | file/string                | `sha1 file.zip`,`sha1 "Hash this"`     |
| `sha256`             | hash file or string with SHA256  | file/string                | `sha256 file.zip`,`sha256 "Hash this"` |

---

1. To Edit the theme use `Code $env:POSH_THEME` | `notepad $env:POSH_THEME`
1. To Edit the profile use `Code $PROFILE` | `notepad $PROFILE`
1. for windows terminal `Setting.json` copy the content of [windows terminal.setting.json](<windows terminal.setting.json>) to `setting.json`
