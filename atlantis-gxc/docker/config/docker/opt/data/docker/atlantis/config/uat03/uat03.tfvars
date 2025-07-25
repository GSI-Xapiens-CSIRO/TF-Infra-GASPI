region = "ap-southeast-3"
common-tags = {
  "Owner"       = "gaspi"
  "Environment" = "uat"
}

# cognito users
gaspi-guest-username = "guest@example.com"
gaspi-guest-password = "Guest@Example123!"
gaspi-admin-username = "admin@example.com"
gaspi-admin-password = "Admin@Example123!"
gaspi-admin-email    = "devops@example.com"

# buckets
variants-bucket-prefix      = "gasi-variants-"
metadata-bucket-prefix      = "gasi-metadata-"
lambda-layers-bucket-prefix = "gasi-lambda-layers-"
dataportal-bucket-prefix    = "gasi-dataportal-"

max-request-rate-per-5mins      = 1000
sbeacon-method-queue-size       = 100
sbeacon-method-max-request-rate = 10
svep-method-max-request-rate    = 10
svep-method-queue-size          = 100

ses-source-email = "devops@example.com"
enable-inspector = false

hub_name = "RSSARDJITO"
max-request-rate-per-5mins = 1000
sbeacon-method-queue-size = 100
sbeacon-method-max-request-rate = 10
svep-method-max-request-rate = 10
svep-method-queue-size = 100
svep-warning-thresholds = {
  dp = 10
  filter = "PASS"
  gq = 15
  mq = 30
  qd = 20
  qual = 20
}
svep-filters = {
  clinvar_exclude = [
    "Benign",
    "Benign/Likely benign",
    "Likely benign",
    "not provided",
  ]
  consequence_rank = 14
  max_maf          = 0.05
  genes            = [
    "ABCC8",
    "ABCC9",
    "ACAD9",
    "ACADVL",
    "ACTA1",
    "ACTA2",
    "ACTC1",
    "ACTN2",
    "ACVRL1",
    "ALK",
    "ALPK3",
    "ANO5",
    "APOB",
    "AQP1",
    "ATP13A3",
    "ATP1A2",
    "ATP2A1",
    "B4GAT1",
    "BAG3",
    "BIN1",
    "BMPR2",
    "BVES",
    "CACNA1A",
    "CACNA1C",
    "CACNA1S",
    "CALM1",
    "CALM2",
    "CALM3",
    "CAPN1",
    "CAPN3",
    "CASQ2",
    "CAV1",
    "CAV3",
    "CDH2",
    "CFL2",
    "CLCN1",
    "CNBP",
    "COL12A1",
    "COL1A1",
    "COL1A2",
    "COL3A1",
    "COL5A1",
    "COL5A2",
    "COL6A1",
    "COL6A2",
    "COL6A3",
    "COQ2",
    "COQ8A",
    "CRPPA",
    "CSRP3",
    "DAG1",
    "DES",
    "DMD",
    "DMPK",
    "DNAJB6",
    "DSC2",
    "DSG2",
    "DSP",
    "DYSF",
    "EFEMP2",
    "EIF2AK4",
    "EMD",
    "ENG",
    "EYA4",
    "FBN1",
    "FBN2",
    "FHL1",
    "FKRP",
    "FKTN",
    "FLNA",
    "FLNC",
    "GAA",
    "GATA4",
    "GBE1",
    "GDF2",
    "GLA",
    "GMPPB",
    "HNRNPDL",
    "HSPB1",
    "ISCU",
    "JPH2",
    "JUP",
    "KBTBD13",
    "KCNE1",
    "KCNH2",
    "KCNJ18",
    "KCNJ2",
    "KCNK3",
    "KCNQ1",
    "KLF2",
    "KLHL40",
    "KLHL41",
    "LAMA2",
    "LAMP2",
    "LARGE1",
    "LDLR",
    "LDLRAP1",
    "LIMS2",
    "LIPA",
    "LMNA",
    "LMOD3",
    "LOX",
    "MAP3K20",
    "MCM3AP",
    "MEGF10",
    "MICU1",
    "MMD2",
    "MME",
    "MT-TA",
    "MT-TA",
    "MT-TD",
    "MTM1",
    "MYBPC3",
    "MYH11",
    "MYH7",
    "MYL2",
    "MYL3",
    "MYLK",
    "MYO18B",
    "MYOT",
    "NKX2-5",
    "NOTCH1",
    "NOTCH3",
    "PABPN1",
    "PCSK9",
    "PKP2",
    "PLEC",
    "PLIN4",
    "PLN",
    "POGLUT1",
    "POLG",
    "POLG2",
    "POMGNT1",
    "POMGNT2",
    "POMT1",
    "POMT2",
    "PRKAG2",
    "PRKG1",
    "PYROXD1",
    "RBM20",
    "RXYLT1 ",
    "RYR1",
    "RYR2",
    "SCN10A",
    "SCN3B",
    "SCN4A",
    "SCN5A",
    "SELENON",
    "SEPTIN9",
    "SGCA",
    "SGCB",
    "SGCD",
    "SGCG",
    "SIL1",
    "SLC22A5",
    "SLC25A20",
    "SLC2A10",
    "SMAD3",
    "SMAD4",
    "SMAD9",
    "SOX17",
    "SPEG",
    "SPTBN4",
    "STAC3",
    "SUCLA2",
    "SUCLG1",
    "SYNE1",
    "TBX20",
    "TBX4",
    "TCAP",
    "TECRL",
    "TGFB2",
    "TGFB3",
    "TGFBR1",
    "TGFBR2",
    "TIA1",
    "TK2",
    "TMEM126B",
    "TMEM43",
    "TNNC1",
    "TNNI3",
    "TNNI3K",
    "TNNT1",
    "TNNT2",
    "TNPO3",
    "TOR1AIP1",
    "TPM1",
    "TPM2",
    "TPM3",
    "TRAPPC11",
    "TRDN",
    "TRIM32",
    "TRPM4",
    "TSFM",
    "TTN",
    "TTR",
    "TYMP",
    "UTRN",
    "VCL",
    "VMA21",
  ]
}