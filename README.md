# HelloID-Conn-Prov-Target-Raet-DPIA100
Target connector for creation of DPIA100 (Beaufort)

This connector contains the DPIA100 target for creating a DPIA100 export for Raet Beaufort to import some generated data from the HelloID provisioning module. This functionality will be replaced by writing back the desired values by the IAM-API (not supported yet)

This version is created for export only rubriekcode P01035 (emailadrress work)

Please change the following variabled to your own environment:
$User -> This is the user for performing the import into Beaufort
$OutFile -> Export path including filename (this example with date)
$Rubriekscode -> This is the rubriekcode for importing emailaddress to Beafort