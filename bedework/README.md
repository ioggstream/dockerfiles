# Bedework Caldav Server Image

Bedework is a web and caldav server served via jboss. 

This image runs a bedework quickstart with a full featured caldav server.

## Running bedework

Run the quickstart with:

    #docker run -p 8080:8080 bedework

Access the web applications at:

  - http://localhost:8080/bedework  - main menu

Make a simple caldav request with one of the already-provisioned users:

    #curl -v http://vbede:bedework@localhost:8080/ucaldav/user/vbede/


## Configure bedework

To configure bedework with:

  - a separate datastore (eg. mysql)
  - a custom directory server 
  - whatever

See https://wiki.jasig.org/display/BWK310/Running+Bedework


