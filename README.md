# HelloID-Conn-Prov-Target-Raet-DPIA100

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |

<p align="center">
  <img src="https://user-images.githubusercontent.com/69046642/170068731-d6609cc7-2b27-416c-bbf4-df65e5063a36.png">
</p>

## Versioning
| Version | Description | Date |
| - | - | - |
| 1.1.0   | Updated to dynamically build rows for file based on account object | 2023/01/24  |
| 1.0.0   | Initial release | 2020/09/24  |

## Table of contents
- [HelloID-Conn-Prov-Target-Raet-DPIA100](#helloid-conn-prov-target-raet-dpia100)
  - [Versioning](#versioning)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
    - [Connection settings](#connection-settings)
    - [Prerequisites](#prerequisites)
    - [Remarks](#remarks)
  - [Getting help](#getting-help)
  - [HelloID docs](#helloid-docs)
  
---

## Introduction

Target connector for creation of local DPIA100 (Beaufort) file

This connector can create a local DPIA100 export file for Raet Beaufort to import (manual import) some generated data from the HelloID provisioning module. This functionality will at one moment be replaced by writing back the desired values by the RAET IAM-API.

Please setup the connector following the DPIA100 requirements of the customer. 
You can choose between an export per day, or a DPIA100 export per person.

### Connection settings
The following settings are required to run the source import.

| Setting                   | Description                                                                   | Mandatory   |
| ------------------------- | ----------------------------------------------------------------------------- | ----------- |
| DPIA100 Export Format     | The choice between a single file per person or a daily file.                  | Yes         |
| DPIA100 Path              | The location where the DPIA100 file should be created.                        | Yes         |
| DPIA100 Filename Prefix   | The prefix of the where the DPIA100 file.                                     | Yes         |
| DPIA100 Update User       | The User that is set as the "updater" in the DPIA100 file.                    | Yes         |
| DPIA100 Process Code      | The Process Code that is set in the DPIA100 file.                             | Yes         |
| DPIA100 Indication        | The Indication that is set in the DPIA100 file (V for Variable S for Stam).   | Yes         |
| Toggle Debug Logging      | Enable extra logging yes/no. Should only be used for debug purposes.          | No          |

### Prerequisites
 - None currently known.

### Remarks
 - Currently, this local DPIA100 file has to be manually imported into Beaufort.

## Getting help
> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/hc/en-us/articles/360012558020-Configure-a-custom-PowerShell-target-system) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID docs
The official HelloID documentation can be found at: https://docs.helloid.com/