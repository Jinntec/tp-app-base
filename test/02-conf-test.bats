#!/usr/bin/env bats
#
# Test configuration changes to be in effect
# These tests expect a running container at port 8080 with the name "exist"

@test "logs show no eXide deployment from autodeploy" {
  result=$(docker logs exist | grep -om 1 'http://exist-db.org/apps/eXide')
  [ "$result" != 'http://exist-db.org/apps/eXide' ]
}

@test "logs show publisher lib deployment from autodeploy" {
  result=$(docker logs exist | grep -om 1 'http://existsolutions.com/apps/tei-publisher-lib')
  [ "$result" == 'http://existsolutions.com/apps/tei-publisher-lib' ]
}

@test "XSS fails via http" {
  result=$(curl -s --location --globoff 'http://127.0.0.1:8080/exist/rest/db?_query=declare%20option%20exist%3Aserialize%20%22method%3Dhtml%20media-type%3Dtext%2Fhtml%22%3B%20element%20html%20{element%20script%20{%22alert(%27XSS%27)%22}}&_wrap=no' | grep -o 'XSS')
  [ "$result" != 'XSS' ]
}

@test "xsl submitted via query does not execute" {
  result=$(curl -s --location 'http://127.0.0.1:8080/exist/rest/db' --header 'Content-Type: text/xml' --data-binary @test/fixtures/query_xsl.xml | grep -o -m 1 'nobody' | head -1)
  [ "$result" != 'nobody' ]
}

@test "XXE mitigation is active" {
  result=$(curl --location 'http://127.0.0.1:8080/exist/rest/db' --data-binary @test/fixtures/xxe.xml | grep -o -m 1 'nobody' | head -1)
  [ "$result" != 'nobody' ]
}
