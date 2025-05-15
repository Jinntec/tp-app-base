<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:webapp="http://xmlns.jcp.org/xml/ns/javaee"
    version="1.0"
>

    <!-- 
    Security configuration for web.xml
    Documentation: https://exist-db.org/exist/apps/doc/production_good_practice#sect-attack-surface
    
    This transformation implements the following security measures for the REST server:
    1. Hides the REST server from direct access
    2. Restricts XQuery submissions to authenticated users
    3. Disables XUpdate submissions
    4. Disables the RESTXQ servlet by commenting it out
    -->

    <xsl:output method="xml" indent="yes" omit-xml-declaration="no" />

    <!-- Hide REST server and restrict XQuery/XUpdate submissions -->
    <xsl:template match="webapp:servlet[webapp:servlet-name = 'REST']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="webapp:servlet-name"/>
            <xsl:apply-templates select="webapp:servlet-class"/>
            <xsl:apply-templates select="webapp:init-param[webapp:param-name != 'hidden' and webapp:param-name != 'xquery-submission' and webapp:param-name != 'xupdate-submission']"/>
            
            <!-- Set REST server to hidden -->
            <init-param>
                <param-name>hidden</param-name>
                <param-value>true</param-value>
            </init-param>
            
            <!-- Restrict XQuery submissions to authenticated users -->
            <init-param>
                <param-name>xquery-submission</param-name>
                <param-value>authenticated</param-value>
            </init-param>
            
            <!-- Disable XUpdate submissions -->
            <init-param>
                <param-name>xupdate-submission</param-name>
                <param-value>disabled</param-value>
            </init-param>
            
            <xsl:apply-templates select="webapp:load-on-startup"/>
        </xsl:copy>
    </xsl:template>

    <!-- Comment out RESTXQ servlet -->
    <xsl:template match="webapp:servlet[webapp:servlet-name='RestXqServlet']">
        <xsl:comment>
            <xsl:apply-templates select="." mode="comment"/>
        </xsl:comment>
    </xsl:template>

    <!-- Template for formatting elements in comments -->
    <xsl:template match="*" mode="comment">
        <xsl:text>&#10;    </xsl:text>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="comment"/>
        </xsl:copy>
        <xsl:text>&#10;    </xsl:text>
    </xsl:template>

    <!-- Template for attributes in comments -->
    <xsl:template match="@*" mode="comment">
        <xsl:copy/>
    </xsl:template>

    <!-- Template for text nodes in comments -->
    <xsl:template match="text()" mode="comment">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- Copy all other nodes unchanged -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet> 