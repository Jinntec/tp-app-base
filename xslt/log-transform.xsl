<?xml version="1.0" encoding="UTF-8"?>
<!--

    eXist-db Open Source Native XML Database
    Copyright (C) 2001 The eXist-db Authors

    info@exist-db.org
    http://www.exist-db.org

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  <xsl:output method="xml" indent="yes" omit-xml-declaration="no" />

  <!-- Match Root elements with attribute level='info' and Logger elements with attribute
  name='org.exist.repo' -->
  <xsl:template
    match="Root[@level = 'info'][not(AppenderRef[@ref='STDOUT'])] | Logger[@name = 'org.exist.repo'][not(AppenderRef[@ref='STDOUT'])]">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
      <AppenderRef ref="STDOUT" />
    </xsl:copy>
  </xsl:template>

  <!-- Identity transform -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>