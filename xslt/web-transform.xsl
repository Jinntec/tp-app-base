<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jakartaee="https://jakarta.ee/xml/ns/jakartaee"
    xmlns:javaee="http://xmlns.jcp.org/xml/ns/javaee"
    exclude-result-prefixes="jakartaee javaee"
    version="1.0"
>
    <xsl:output
        method="xml"
        indent="yes"
        omit-xml-declaration="no"
        encoding="UTF-8"
    />

    <!-- Identity transform for all nodes and attributes -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" />
        </xsl:copy>
    </xsl:template>

    <!-- Match EXistServlet in Java EE namespace -->
    <xsl:template match="javaee:servlet[javaee:servlet-name='EXistServlet']">
        <servlet xmlns="http://xmlns.jcp.org/xml/ns/javaee">
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates
                select="javaee:servlet-name | javaee:servlet-class"
            />
            <xsl:apply-templates
                select="javaee:init-param[not(
                javaee:param-name='hidden' or
                javaee:param-name='xquery-submission' or
                javaee:param-name='xupdate-submission')]"
            />

            <!-- Add secured parameters -->
            <init-param>
                <param-name>hidden</param-name>
                <param-value>true</param-value>
            </init-param>
            <init-param>
                <param-name>xquery-submission</param-name>
                <param-value>authenticated</param-value>
            </init-param>
            <init-param>
                <param-name>xupdate-submission</param-name>
                <param-value>disabled</param-value>
            </init-param>

            <xsl:apply-templates select="javaee:load-on-startup" />
        </servlet>
    </xsl:template>

    <!-- Match EXistServlet in Jakarta EE namespace -->
    <xsl:template
        match="jakartaee:servlet[jakartaee:servlet-name='EXistServlet']"
    >
        <servlet xmlns="https://jakarta.ee/xml/ns/jakartaee">
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates
                select="jakartaee:servlet-name | jakartaee:servlet-class"
            />
            <xsl:apply-templates
                select="jakartaee:init-param[not(
                jakartaee:param-name='hidden' or
                jakartaee:param-name='xquery-submission' or
                jakartaee:param-name='xupdate-submission')]"
            />

            <!-- Add secured parameters -->
            <init-param>
                <param-name>hidden</param-name>
                <param-value>true</param-value>
            </init-param>
            <init-param>
                <param-name>xquery-submission</param-name>
                <param-value>authenticated</param-value>
            </init-param>
            <init-param>
                <param-name>xupdate-submission</param-name>
                <param-value>disabled</param-value>
            </init-param>

            <xsl:apply-templates select="jakartaee:load-on-startup" />
        </servlet>
    </xsl:template>

    <!-- Comment out RestXqServlet in Java EE namespace -->
    <xsl:template match="javaee:servlet[javaee:servlet-name='RestXqServlet']">
        <xsl:call-template name="comment-element" />
    </xsl:template>

    <!-- Comment out RestXqServlet in Jakarta EE namespace -->
    <xsl:template
        match="jakartaee:servlet[jakartaee:servlet-name='RestXqServlet']"
    >
        <xsl:call-template name="comment-element" />
    </xsl:template>

    <!-- Comment out RestXqServlet mapping in Java EE namespace -->
    <xsl:template
        match="javaee:servlet-mapping[javaee:servlet-name='RestXqServlet']"
    >
        <xsl:call-template name="comment-element" />
    </xsl:template>

    <!-- Comment out RestXqServlet mapping in Jakarta EE namespace -->
    <xsl:template
        match="jakartaee:servlet-mapping[jakartaee:servlet-name='RestXqServlet']"
    >
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

    <!-- Templates for comment mode -->
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
