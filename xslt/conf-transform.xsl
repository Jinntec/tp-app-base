<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:exist="http://exist.sourceforge.net/NS/exist"
    xmlns:log4j="http://jakarta.apache.org/log4j/"
    xmlns:webapp="http://xmlns.jcp.org/xml/ns/javaee"
    exclude-result-prefixes="xs exist log4j webapp"
    version="1.0"
>

    <!-- 
    Security configuration for conf.xml
    Documentation: https://exist-db.org/exist/apps/doc/production_good_practice#sect-attack-surface
    
    This transformation implements the following security measures:
    1. Disables Java binding in XQuery
    2. Disables XML external entity processing
    3. Enables secure processing features
    4. Disables the lock table
    5. Disables RESTXQ extension modules by commenting them out
    6. Disables RESTXQ startup trigger by commenting it out
    -->

    <xsl:output method="xml" indent="yes" omit-xml-declaration="no" />

    <!-- Ensure Java binding is disabled -->
    <xsl:template match="xquery">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:if test="name() != 'enable-java-binding'">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
            <xsl:attribute name="enable-java-binding">no</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Ensure lock-table is disabled -->
    <xsl:template match="lock-table">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:if test="name() != 'disabled'">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
            <xsl:attribute name="disabled">true</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Comment out RESTXQ extension modules -->
    <xsl:template match="module[contains(@class, 'RestXqModule') or contains(@class, 'ExistRestXqModule')]">
        <xsl:comment>
            <xsl:apply-templates select="." mode="comment"/>
        </xsl:comment>
    </xsl:template>

    <!-- Comment out RESTXQ startup trigger -->
    <xsl:template match="trigger[contains(@class, 'RestXqStartupTrigger')]">
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

    <!-- Ensure XML parser features are set correctly -->
    <xsl:template match="parser">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="xml">
                    <xsl:apply-templates select="xml">
                        <xsl:with-param name="add-features" select="true()"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xml>
                        <features>
                            <feature name="http://xml.org/sax/features/external-general-entities" value="false"/>
                            <feature name="http://xml.org/sax/features/external-parameter-entities" value="false"/>
                            <feature name="http://javax.xml.XMLConstants/feature/secure-processing" value="true"/>
                        </features>
                    </xml>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()[not(self::xml)]"/>
        </xsl:copy>
    </xsl:template>

    <!-- Handle xml element and its features -->
    <xsl:template match="xml">
        <xsl:param name="add-features" select="false()"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="features">
                    <xsl:apply-templates select="features">
                        <xsl:with-param name="add-features" select="$add-features"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <features>
                        <feature name="http://xml.org/sax/features/external-general-entities" value="false"/>
                        <feature name="http://xml.org/sax/features/external-parameter-entities" value="false"/>
                        <feature name="http://javax.xml.XMLConstants/feature/secure-processing" value="true"/>
                    </features>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()[not(self::features)]"/>
        </xsl:copy>
    </xsl:template>

    <!-- Handle features element -->
    <xsl:template match="features">
        <xsl:param name="add-features" select="false()"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="feature"/>
            <xsl:if test="$add-features">
                <xsl:if test="not(feature[@name='http://xml.org/sax/features/external-general-entities'])">
                    <feature name="http://xml.org/sax/features/external-general-entities" value="false"/>
                </xsl:if>
                <xsl:if test="not(feature[@name='http://xml.org/sax/features/external-parameter-entities'])">
                    <feature name="http://xml.org/sax/features/external-parameter-entities" value="false"/>
                </xsl:if>
                <xsl:if test="not(feature[@name='http://javax.xml.XMLConstants/feature/secure-processing'])">
                    <feature name="http://javax.xml.XMLConstants/feature/secure-processing" value="true"/>
                </xsl:if>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="validation">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="not(@enable-entity-resolver)">
                <xsl:attribute name="enable-entity-resolver">false</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
