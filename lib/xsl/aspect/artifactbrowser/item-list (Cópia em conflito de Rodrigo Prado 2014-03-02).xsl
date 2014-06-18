<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov
-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">

    <xsl:output indent="yes"/>

    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->

    <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/>
        <xsl:choose>
            <xsl:when test="'file' = $emphasis">


                <div class="item-wrapper clearfix">
                    <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
                    <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                         mode="itemSummaryList-DIM-file"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-file">
        <xsl:param name="href"/>
        <xsl:variable name="metadataWidth" select="675 - $thumbnail.maxwidth - 30"/>
        <div class="item-metadata" style="width: {$metadataWidth}px;">
            <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.title</i18n:text><xsl:text>:</xsl:text></span>
            <span class="content" style="width: {$metadataWidth - 110}px;">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </span>
            <span class="Z3988">
                <xsl:attribute name="title">
                    <xsl:call-template name="renderCOinS"/>
                </xsl:attribute>
                &#xFEFF; <!-- non-breaking space to force separating the end tag -->
            </span>
            <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.author</i18n:text><xsl:text>:</xsl:text></span>
            <span class="content" style="width: {$metadataWidth - 110}px;">
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <span>
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class">
                                        <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.date</i18n:text><xsl:text>:</xsl:text></span>
                <span class="content" style="width: {$metadataWidth - 110}px;">
                    <xsl:value-of
                            select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                </span>
            </xsl:if>
        </div>
    </xsl:template>

    <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description">

			<div class="artifact-title-item-list">
				<!-- imagem de capa do item -->
				<span class="image-capa">
					<img>
						<xsl:choose>	
							<xsl:when test="dim:field[@element='description' and @qualifier='capa']">			
								<xsl:attribute name="src">
									<xsl:value-of select="dim:field[@element='description' and @qualifier='capa']/node()" />
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="src">
									<!--/static/images/capa_branco.jpg-->
									/static/images/capa_indisponivel.jpg
								</xsl:attribute>
							</xsl:otherwise>						
							
						</xsl:choose>
						<xsl:attribute name="style">
							width: 80px; height: 120px;
						</xsl:attribute>
					</img>
				</span>
			</div>				

			<div class="artifact-info-item-list">
			
				<!-- MFN dc.identifier.mfn 
                <xsl:if test="dim:field[@element='identifier' and @qualifier='mfn']">
	                <span class="mfn bold">
						<xsl:copy-of select="dim:field[@element='identifier' and @qualifier='mfn']/node()"/>
	                </span>
                </xsl:if>
				-->

				<!-- autores, separados por ponto e virgula -->
				<span class="author">
                    <xsl:choose>
                        <xsl:when test="dim:field[@qualifier='author']">
                            <xsl:for-each select="dim:field[@qualifier='author']">
                                <span>
                                  <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                </span>
                <xsl:text>. </xsl:text>
				
				<!-- titulo -->
				<span class="title bold">
					<xsl:value-of select="dim:field[@element='title'][1]/node()"/>
					<xsl:text>. </xsl:text>
				</span>

				<!-- colaboradores/tradutores separados por ponto e virgula dc.contributor.tradutor -->	
				<xsl:if test="dim:field[@element='contributor' and @qualifier='tradutor']">
					<span class="contributor">
						<xsl:choose>
							<xsl:when test="dim:field[@element='contributor' and @qualifier='tradutor']">
								<!--<xsl:text> Trad. </xsl:text>-->
								<xsl:for-each select="dim:field[@element='contributor' and @qualifier='tradutor']">
									<xsl:copy-of select="node()"/>
									<xsl:if test="count(following-sibling::dim:field[@element='contributor' and @qualifier='tradutor']) != 0">
										<xsl:text>; </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:when>
						</xsl:choose>
					</span>
					<xsl:text>. </xsl:text>
				</xsl:if>
				
				<!-- colaboradores/ilustradores separados por ponto e virgula dc.contributor.illustrator -->
				<xsl:if test="dim:field[@element='contributor' and @qualifier='illustrator']">				
					<span class="contributor">
						<xsl:choose>
							<xsl:when test="dim:field[@element='contributor' and @qualifier='illustrator']">
								<xsl:text> Ilus. </xsl:text>
								<xsl:for-each select="dim:field[@element='contributor' and @qualifier='illustrator']">
									<xsl:copy-of select="node()"/>
									<xsl:if test="count(following-sibling::dim:field[@element='contributor' and @qualifier='illustrator']) != 0">
										<xsl:text>; </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:when>
						</xsl:choose>
					</span>
					<xsl:text>. </xsl:text>
				</xsl:if>
				
				<!-- edição do item, se tiver -->	
				<xsl:if test="count(dim:field[@element='relation' and @qualifier='hasversion']) = 1">
					<xsl:copy-of select="dim:field[@element='relation' and @qualifier='hasversion']"/> 
					<xsl:text>.p. </xsl:text>
				</xsl:if>
				
				<!-- local - dc.coverage.spatial -->	
				<xsl:copy-of select="dim:field[@element='coverage' and @qualifier='spatial']/node()"/>
				<xsl:text>  : </xsl:text>
				
				<!-- editora -->
                <xsl:if test="dim:field[@element='publisher']">
	                <span class="publisher">
						<xsl:copy-of select="dim:field[@element='publisher']/node()"/> 
	                </span>
                </xsl:if>
				<xsl:text>, </xsl:text>
				
				<!-- ano de publicação -->
				<xsl:copy-of select="dim:field[@element='date' and @qualifier='created']/node()"/> 
				<xsl:text>. </xsl:text>
				
				<!-- se só tiver um extent mostra p. -->
				<xsl:if test="count(dim:field[@element='format' and @qualifier='extent']) = 1">
					<xsl:copy-of select="dim:field[@element='format' and @qualifier='extent']"/> 
					<xsl:text> p. </xsl:text>
				</xsl:if>

				<!-- format -->
				<xsl:if test="count(dim:field[@element='format' and @qualifier='extent']) > 1">
				<xsl:copy-of select="dim:field[@element='format'][1]"/> 
				<xsl:text>. </xsl:text>
				</xsl:if>

				<!-- serie - dc.relation.ispartofseries -->
                <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries']">
	                <span class="serie">
						<xsl:text>(</xsl:text>
						<xsl:copy-of select="dim:field[@element='relation' and @qualifier='ispartofseries']/node()"/> 
						<xsl:text>)</xsl:text>
	                </span>
                </xsl:if>
				
				<!-- Faixa etária -->
                <xsl:if test="dim:field[@element='description' and @qualifier='agegroup']">
	                <p class="agegroup bold">
						<xsl:copy-of select="dim:field[@element='description' and @qualifier='agegroup']/node()"/> 
	                </p>
                </xsl:if>				

				<!-- Recomendação Saci-->
				<xsl:if test="(dim:field[@element = 'description' and @qualifier='saci']) = 's'">
					<span class="saci">
						<span class="logo-saci" title="O Saci recomenda" ></span>
					</span>
				</xsl:if>
						
				<!-- Resenha -->
				<xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
					<div class="resenha">
						<xsl:element name="span">
							<xsl:attribute name="onClick">
								mostraResenha(
									'<xsl:value-of select="dim:field[@element='title'][1]/node()"/>', 
									'<xsl:copy-of select="dim:field[@element='description' and @qualifier='abstract']/node()"/>')
							</xsl:attribute>
							<xsl:attribute name="title">
								Clique aqui para ler a resenha desse livro
							</xsl:attribute>							
							Resenha
						</xsl:element>
					</div>				
				</xsl:if>
				
				<div class="registro-completo">
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:value-of select="$href" />?show=full
						</xsl:attribute>
						registro completo
					</xsl:element>
				</div>
				
            <!--
			<xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
                <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
                <div class="artifact-abstract">
                    <xsl:value-of select="util:shortenString($abstract, 220, 10)"/>
                </div>
            </xsl:if>
			-->
			</div>
        
		</div>
		<div class="clear"> </div>
    </xsl:template>

    <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <div class="thumbnail-wrapper">
            <div class="artifact-preview">
                <a class="image-link" href="{$href}">
                    <xsl:choose>
                        <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of
                                            select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
                        </xsl:when>
                        <xsl:otherwise>
                            <img alt="Icon" src="{concat($theme-path, '/images/mime.png')}" style="height: {$thumbnail.maxheight}px;"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </div>
        </div>
	</xsl:template>
</xsl:stylesheet>
