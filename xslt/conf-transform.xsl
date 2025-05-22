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

    <!-- Define security feature names as variables -->
    <xsl:variable
        name="external-general-entities"
    >http://xml.org/sax/features/external-general-entities</xsl:variable>
    <xsl:variable
        name="external-parameter-entities"
    >http://xml.org/sax/features/external-parameter-entities</xsl:variable>
    <xsl:variable
        name="secure-processing"
    >http://javax.xml.XMLConstants/feature/secure-processing</xsl:variable>

    <!-- Ensure Java binding is disabled - match at any depth -->
    <xsl:template match="xquery | */xquery | */*/xquery">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:if test="name() != 'enable-java-binding'">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:for-each>
            <xsl:attribute name="enable-java-binding">no</xsl:attribute>
            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>

    <!-- Ensure lock-table is disabled - match at any depth -->
    <xsl:template match="lock-table | */lock-table | */*/lock-table">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:if test="name() != 'disabled'">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:for-each>
            <xsl:attribute name="disabled">true</xsl:attribute>
            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>

    <!-- Comment out RESTXQ extension modules - match at any depth -->
    <xsl:template
        match="module[contains(@class, 'RestXqModule') or contains(@class, 'ExistRestXqModule')] |
                         */module[contains(@class, 'RestXqModule') or contains(@class, 'ExistRestXqModule')] |
                         */*/module[contains(@class, 'RestXqModule') or contains(@class, 'ExistRestXqModule')]"
    >
        <xsl:call-template name="comment-element" />
    </xsl:template>

    <!-- Comment out RESTXQ startup trigger - match at any depth -->
    <xsl:template
        match="trigger[contains(@class, 'RestXqStartupTrigger')] |
                         */trigger[contains(@class, 'RestXqStartupTrigger')] |
                         */*/trigger[contains(@class, 'RestXqStartupTrigger')]"
    >
        <xsl:call-template name="comment-element" />
    </xsl:template>

    <!-- Reusable template for commenting out elements -->
    <xsl:template name="comment-element">
        <xsl:comment>
            <xsl:text>&#10;    </xsl:text>
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="comment" />
            </xsl:copy>
            <xsl:text>&#10;    </xsl:text>
        </xsl:comment>
    </xsl:template>

    <!-- Template for formatting elements in comments -->
    <xsl:template match="*" mode="comment">
        <xsl:text>&#10;    </xsl:text>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="comment" />
        </xsl:copy>
        <xsl:text>&#10;    </xsl:text>
    </xsl:template>

    <!-- Template for attributes in comments -->
    <xsl:template match="@*" mode="comment">
        <xsl:copy />
    </xsl:template>

    <!-- Template for text nodes in comments -->
    <xsl:template match="text()" mode="comment">
        <xsl:value-of select="." />
    </xsl:template>

    <!-- Ensure XML parser features are set correctly - match at any depth -->
    <xsl:template match="parser | */parser | */*/parser">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:choose>
                <xsl:when test="xml">
                    <xsl:apply-templates select="xml">
                        <xsl:with-param name="add-features" select="true()" />
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xml>
                        <features>
                            <feature
                                name="{$external-general-entities}"
                                value="false"
                            />
                            <feature
                                name="{$external-parameter-entities}"
                                value="false"
                            />
                            <feature name="{$secure-processing}" value="true" />
                        </features>
                    </xml>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()[not(self::xml)]" />
        </xsl:copy>
    </xsl:template>

    <!-- Handle xml element and its features -->
    <xsl:template match="xml | */xml | */*/xml">
        <xsl:param name="add-features" select="false()" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:choose>
                <xsl:when test="features">
                    <xsl:apply-templates select="features">
                        <xsl:with-param
                            name="add-features"
                            select="$add-features"
                        />
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <features>
                        <feature
                            name="{$external-general-entities}"
                            value="false"
                        />
                        <feature
                            name="{$external-parameter-entities}"
                            value="false"
                        />
                        <feature name="{$secure-processing}" value="true" />
                    </features>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()[not(self::features)]" />
        </xsl:copy>
    </xsl:template>

    <!-- Handle features element with XSLT 1.0 compatible checking -->
    <xsl:template match="features | */features | */*/features">
        <xsl:param name="add-features" select="false()" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="feature" />

            <!-- Add missing security features if needed -->
            <xsl:if test="$add-features">
                <xsl:if test="not(feature[@name=$external-general-entities])">
                    <feature
                        name="{$external-general-entities}"
                        value="false"
                    />
                </xsl:if>
                <xsl:if test="not(feature[@name=$external-parameter-entities])">
                    <feature
                        name="{$external-parameter-entities}"
                        value="false"
                    />
                </xsl:if>
                <xsl:if test="not(feature[@name=$secure-processing])">
                    <feature name="{$secure-processing}" value="true" />
                </xsl:if>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- Ensure entity resolver is disabled - match at any depth -->
    <xsl:template match="validation | */validation | */*/validation">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:if test="name() != 'enable-entity-resolver'">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:for-each>
            <xsl:attribute name="enable-entity-resolver">false</xsl:attribute>
            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>

    <!-- Identity transform for all other nodes and attributes -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>