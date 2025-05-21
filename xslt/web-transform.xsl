<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:web="https://jakarta.ee/xml/ns/jakartaee"
    exclude-result-prefixes="web"
    version="1.0"
>
    <xsl:output method="xml" indent="yes" omit-xml-declaration="no" encoding="UTF-8"/>

    <!-- Match EXistServlet using namespace prefix -->
    <xsl:template match="web:servlet[web:servlet-name='EXistServlet']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="web:servlet-name | web:servlet-class"/>
            <xsl:apply-templates select="web:init-param[not(web:param-name='hidden' or web:param-name='xquery-submission' or web:param-name='xupdate-submission')]"/>

            <!-- Inject secure init-param values -->
            <init-param xmlns="https://jakarta.ee/xml/ns/jakartaee">
                <param-name>hidden</param-name>
                <param-value>true</param-value>
            </init-param>
            <init-param xmlns="https://jakarta.ee/xml/ns/jakartaee">
                <param-name>xquery-submission</param-name>
                <param-value>authenticated</param-value>
            </init-param>
            <init-param xmlns="https://jakarta.ee/xml/ns/jakartaee">
                <param-name>xupdate-submission</param-name>
                <param-value>disabled</param-value>
            </init-param>

            <xsl:apply-templates select="web:load-on-startup"/>
        </xsl:copy>
    </xsl:template>

    <!-- Comment out RESTXQ servlet safely -->
    <xsl:template match="web:servlet[web:servlet-name='RestXqServlet']">
        <!-- Mode 'comment' is used to serialize element in a comment -->
        <xsl:comment>
            <xsl:apply-templates select="." mode="comment"/>
        </xsl:comment>
    </xsl:template>

    <!-- Format elements for comment mode -->
    <xsl:template match="*" mode="comment">
        <xsl:text>&#10;    </xsl:text>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="comment"/>
        </xsl:copy>
        <xsl:text>&#10;    </xsl:text>
    </xsl:template>

    <xsl:template match="@*" mode="comment">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="text()" mode="comment">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- Copy other servlet elements -->
    <xsl:template match="web:servlet">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Identity transform for all other nodes and attributes -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <!-- Preserve comments -->
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>

</xsl:stylesheet>