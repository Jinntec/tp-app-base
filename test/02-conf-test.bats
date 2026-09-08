#!/usr/bin/env bats
#
# Test configuration changes to be in effect
# These tests expect a running container at port 8080 with the name "exist"

@test "logs show no eXide deployment from autodeploy" {
  result=$(docker logs exist | grep -om 1 'http://exist-db.org/apps/eXide' | tr -d '\n')
  [ -z "$result" ]
}

@test "logs show publisher lib deployment from autodeploy" {
  result=$(docker logs exist | grep -om 1 'http://existsolutions.com/apps/tei-publisher-lib')
  [ "$result" == 'http://existsolutions.com/apps/tei-publisher-lib' ]
}

@test "XSS fails via http" {
  response=$(curl -s -w '\n%{http_code}' --location --globoff 'http://127.0.0.1:8080/exist/rest/db?_query=declare%20option%20exist%3Aserialize%20%22method%3Dhtml%20media-type%3Dtext%2Fhtml%22%3B%20element%20html%20{element%20script%20{%22alert(%27XSS%27)%22}}&_wrap=no')
  status=$(echo "$response" | tail -n1)
  body=$(echo "$response" | sed '$d')
  # request must be rejected outright ...
  [ "$status" = "403" ]
  # ... and no live <script> tag must reach the client, regardless of the
  # error page reflecting the raw query string back (e.g. Jetty 12's default
  # 403 page includes the request URI, which harmlessly contains "XSS")
  script=$(echo "$body" | grep -o '<script>' | tr -d '\n')
  [ -z "$script" ]
}

@test "xsl submitted via query does not execute" {
  result=$(curl -s --location 'http://127.0.0.1:8080/exist/rest/db' --header 'Content-Type: text/xml' --data-binary @test/fixtures/query_xsl.xml | grep -o -m 1 'nobody' | head -1 )
  [ -z "$result" ]
}

@test "XXE mitigation is active" {
  result=$(curl -s --location 'http://127.0.0.1:8080/exist/apps/tei-publisher/api/preview' --header 'Content-Type: application/xml' --data-binary @test/fixtures/xxe.xml | grep -o 'nobody' | head -1 | tr -d '\n')
  [ -z "$result" ]
}
