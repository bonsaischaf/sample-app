# Sample app for demonstrating deployment pipelines

deploy to azure:
- packer.env has the credentials. Don't commit!!!
- repo must be created manually
- chekcout sample-app to repo/


tree:
<pre>
.
├── packer.env
├── repo
│   └── sample-app
│       ├── azure.json
│       ├── Jenkinsfile
│       ├── packer
│       │   └── scripts
│       │       ├── createi_admin.sh
│       │       ├── deploy.sh
│       │       ├── deprovision.sh
│       │       └── java.sh
│       ├── pom.xml
│       ├── readme.md
│       ├── src
│       │   └── main
│       │       └── java
│       │           └── hello
│       │               ├── Application.java
│       │               └── HelloController.java
│       └── target
│           ├── classes
│           │   └── hello
│           │       ├── Application.class
│           │       └── HelloController.class
│           ├── generated-sources
│           │   └── annotations
│           ├── gs-spring-boot-0.1.0.jar
│           ├── gs-spring-boot-0.1.0.jar.original
│           ├── maven-archiver
│           │   └── pom.properties
│           └── maven-status
│               └── maven-compiler-plugin
│                   └── compile
│                       └── default-compile
│                           ├── createdFiles.lst
│                           └── inputFiles.lst
└── Vagrantfile

18 directories, 19 files
</pre>
