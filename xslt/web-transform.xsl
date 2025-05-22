<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jakartaee="https://jakarta.ee/xml/ns/jakartaee"
    xmlns:javaee="http://xmlns.jcp.org/xml/ns/javaee"
    exclude-result-prefixes="jakartaee javaee"
    version="1.0">

  <xsl:output method="xml" indent="yes" omit-xml-declaration="no" encoding="UTF-8" />

  <!-- Identity transform -->
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" />
    </xsl:copy>
  </xsl:template>

  <!-- Java EE: patch EXistServlet -->
  <xsl:template match="javaee:servlet[javaee:servlet-name='EXistServlet']">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
      <xsl:if test="not(javaee:init-param[javaee:param-name='hidden'])">
        <init-param>
          <param-name>hidden</param-name>
          <param-value>true</param-value>
        </init-param>
      </xsl:if>
      <xsl:if test="not(javaee:init-param[javaee:param-name='xquery-submission'])">
        <init-param>
          <param-name>xquery-submission</param-name>
          <param-value>authenticated</param-value>
        </init-param>
      </xsl:if>
      <xsl:if test="not(javaee:init-param[javaee:param-name='xupdate-submission'])">
        <init-param>
          <param-name>xupdate-submission</param-name>
          <param-value>disabled</param-value>
        </init-param>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Override param values in javaee -->
  <xsl:template match="javaee:init-param[javaee:param-name='hidden']/javaee:param-value">
    <param-value>true</param-value>
  </xsl:template>

  <xsl:template match="javaee:init-param[javaee:param-name='xquery-submission']/javaee:param-value">
    <param-value>authenticated</param-value>
  </xsl:template>

  <xsl:template match="javaee:init-param[javaee:param-name='xupdate-submission']/javaee:param-value">
    <param-value>disabled</param-value>
  </xsl:template>

  <!-- Jakarta EE: patch EXistServlet -->
  <xsl:template match="jakartaee:servlet[jakartaee:servlet-name='EXistServlet']">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
      <xsl:if test="not(jakartaee:init-param[jakartaee:param-name='hidden'])">
        <init-param>
          <param-name>hidden</param-name>
          <param-value>true</param-value>
        </init-param>
      </xsl:if>
      <xsl:if test="not(jakartaee:init-param[jakartaee:param-name='xquery-submission'])">
        <init-param>
          <param-name>xquery-submission</param-name>
          <param-value>authenticated</param-value>
        </init-param>
      </xsl:if>
      <xsl:if test="not(jakartaee:init-param[jakartaee:param-name='xupdate-submission'])">
        <init-param>
          <param-name>xupdate-submission</param-name>
          <param-value>disabled</param-value>
        </init-param>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Override param values in jakartaee -->
  <xsl:template match="jakartaee:init-param[jakartaee:param-name='hidden']/jakartaee:param-value">
    <param-value>true</param-value>
  </xsl:template>

  <xsl:template match="jakartaee:init-param[jakartaee:param-name='xquery-submission']/jakartaee:param-value">
    <param-value>authenticated</param-value>
  </xsl:template>

  <xsl:template match="jakartaee:init-param[jakartaee:param-name='xupdate-submission']/jakartaee:param-value">
    <param-value>disabled</param-value>
  </xsl:template>

  <!-- Comment out RestXqServlet and its mapping (JavaEE & JakartaEE) -->
  <xsl:template match="javaee:servlet[javaee:servlet-name='RestXqServlet'] |
                       javaee:servlet-mapping[javaee:servlet-name='RestXqServlet'] |
                       jakartaee:servlet[jakartaee:servlet-name='RestXqServlet'] |
                       jakartaee:servlet-mapping[jakartaee:servlet-name='RestXqServlet']">
    <xsl:call-template name="comment-element" />
  </xsl:template>

  <!-- Template for commenting out elements -->
  <xsl:template name="comment-element">
    <xsl:comment>
      <xsl:text>&#10;    </xsl:text>
      <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="comment" />
      </xsl:copy>
      <xsl:text>&#10;    </xsl:text>
    </xsl:comment>
  </xsl:template>

  <!-- Comment mode templates -->
  <xsl:template match="*" mode="comment">
    <xsl:text>&#10;    </xsl:text>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="comment" />
    </xsl:copy>
    <xsl:text>&#10;    </xsl:text>
  </xsl:template>

  <xsl:template match="@*" mode="comment">
    <xsl:copy />
  </xsl:template>

  <xsl:template match="text()" mode="comment">
    <xsl:value-of select="." />
  </xsl:template>
</xsl:stylesheet>
