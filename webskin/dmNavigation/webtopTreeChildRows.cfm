<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Site Tree Child Rows --->
<!--- @@cachestatus: 0 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfparam name="url.relativeNLevel" default="0">
<cfparam name="url.bReloadBranch" default="false">
<cfparam name="url.bLoadRoot" default="false">
<cfparam name="url.loadCollapsed" default="false">
<cfparam name="url.responsetype" default="html">

<cfparam name="stParam.responsetype" default="#url.responsetype#">


<!--- root node --->
<cfset rootObjectID = stObj.objectid>

<!--- tree depth to load --->
<cfset treeLoadingDepth = 2>
<cfset bRenderRoot = true>

<!--- when a relative nlevel has been passed in, do not render the root and  --->
<cfif url.relativeNLevel gt 0>
	<cfset bRenderRoot = false>
	<!--- the loading depth should be increased by 1 when when a relative nlevel has been passed in --->
	<cfset treeLoadingDepth = treeLoadingDepth + 1>
</cfif>
<!--- when reloading a branch, render the root and indent by 1 --->
<cfif url.bReloadBranch>
	<cfset bRenderRoot = true>
	<cfset url.relativeNLevel = url.relativeNLevel + 1>
</cfif>
<!--- when loading the root, render the root and don't indent --->
<cfif url.bLoadRoot>
	<cfset bRenderRoot = true>
	<cfset url.relativeNLevel = 0>
</cfif>



<!--- initialize expanded tree nodes --->
<cfparam name="cookie.FARCRYTREEEXPANDEDNODES" default="">
<!--- add the root node if not loading collapsed --->
<cfif NOT url.loadCollapsed AND NOT listFindNoCase(cookie.FARCRYTREEEXPANDEDNODES, rootObjectID, "|")>
	<cfset cookie.FARCRYTREEEXPANDEDNODES = listAppend(cookie.FARCRYTREEEXPANDEDNODES, rootObjectID, "|")>
</cfif>


<cfset oTree = createObject("component","farcry.core.packages.farcry.tree")>
<cfset qTree = oTree.getDescendants(objectid=rootObjectID, depth=treeLoadingDepth, bIncludeSelf=true)>

<!--- if no tree nodes were found it means the object is missing, since the tree lookup should always "includeSelf" --->
<cfif NOT qTree.recordcount>
	<cfexit method="exittemplate">
</cfif>

<!--- tree depth is relative to the root nlevel of the "page" --->
<cfset baseNLevel = qTree.nlevel>
<cfif NOT bRenderRoot>
	<cfset baseNLevel = baseNLevel - 1>
</cfif>

<cfset treeMaxLevel = baseNLevel + treeLoadingDepth>


<cfset stResponse = structNew()>
<cfset stResponse["rows"] = arrayNew(1)>

<cfsavecontent variable="html">
	
	<cfloop query="qTree">

		<!--- look up the nav node --->
		<cfset stNav = application.fapi.getContentObject(typename="dmNavigation", objectid=qTree.objectid)>

		<cfset thisClass = "">
		<cfset bRootNode = stNav.objectid eq rootObjectID>
		<cfset bExpanded = false>
		<cfset expandable = 0>
		<cfset bUnexpandedAncestor = false>
		<cfset aLeafNodes = arrayNew(1)>
		<cfset childrenLoaded = false>

		<!--- find child folders --->
		<cfif qTree.recordCount gt qTree.currentRow + 1 AND qTree.nlevel[qTree.currentRow+1] gt qTree.nlevel>
			<cfset expandable = 1>
			<cfif qTree.nlevel lt treeMaxLevel>
				<cfset childrenLoaded = true>	
			</cfif>
		</cfif>
		<!--- find child leaves --->
		<cfif arrayLen(stNav.aObjectIDs) gt 0>
			<cfset expandable = 1>
			<cfif qTree.nlevel lt treeMaxLevel>
				<cfset aLeafNodes = oTree.getLeaves(qTree.objectid)>
				<cfset childrenLoaded = true>	
			</cfif>
		</cfif>

		<!--- determine if this node is currently expanded --->
		<cfif bRootNode AND NOT url.loadCollapsed>
			<cfset bExpanded = true>
		</cfif>
		<cfif listFindNoCase(cookie.FARCRYTREEEXPANDEDNODES, stNav.objectid, "|")>
			<cfset expandable = 1>
			<cfset bExpanded = true>
		</cfif>

		<!--- if this node is expanded then show it as collapsable --->
		<cfif bExpanded>
			<cfset thisClass = "fc-treestate-collapse">
		<cfelse>
			<cfset thisClass = "fc-treestate-expand">
		</cfif>


		<!--- tree indentation depth relative to the base nlevel of the page and the expandability of the node --->
		<cfset navIndentLevel = qTree.nlevel - baseNLevel - expandable + url.relativeNLevel>


		<!--- check that all visible ancestors are expanded --->
		<cfset qAncestors = oTree.getAncestors(objectid=qTree.objectid, nlevel=qTree.nlevel-baseNLevel-1)>
		<cfloop query="qAncestors">
			<cfif NOT listFindNoCase(cookie.FARCRYTREEEXPANDEDNODES, qAncestors.objectid, "|") AND qAncestors.nlevel gt 0>
				<!--- unexpanded ancestor found, so this node is not visible --->
				<cfset bUnexpandedAncestor = true>
			</cfif>
		</cfloop>


		<cfif bRenderRoot OR qTree.objectid neq rootObjectID>

			<!--- if this node is expanded, or the parent nav node is expanded then this nav node will be visible --->
			<cfif bUnexpandedAncestor>
				<cfset thisClass = thisClass & " fc-treestate-hidden">
			<cfelseif url.loadCollapsed AND NOT bRootNode>
				<cfset thisClass = thisClass & " fc-treestate-hidden">
			<cfelseif qTree.parentid eq rootObjectID>
				<cfset thisClass = thisClass & " fc-treestate-visible">
			<cfelseif bExpanded OR listFindNoCase(cookie.FARCRYTREEEXPANDEDNODES, qTree.parentid, "|")>
				<cfset thisClass = thisClass & " fc-treestate-visible">
			<cfelse>
				<cfset thisClass = thisClass & " fc-treestate-hidden">
			</cfif>

			<!--- load children using ajax --->
			<cfif expandable AND NOT childrenLoaded>
				<cfset thisClass = thisClass & " fc-treestate-notloaded">
			</cfif>

			<!--- vary the status labels and icon by the object status --->
			<cfset thisStatusLabel = "">
			<cfset thisFolderIcon = "icon-folder-close">
			<cfif bExpanded>
				<cfset thisFolderIcon = "icon-folder-open">
			</cfif>
			<cfset thisNodeIcon = "<span class='icon-stack'><i class='#thisFolderIcon#'></i></span>">

			<cfif stNav.status eq "draft">
				<!--- types object with draft status --->
				<cfset thisStatusLabel = "<span class='label label-warning'>#application.rb.getResource("constants.status.#stNav.status#@label",stNav.status)#</span>">
				<cfset thisNodeIcon = "<span class='icon-stack'><i class='#thisFolderIcon#'></i><i class='icon-pencil'></i></span>">

			<cfelseif stNav.status eq "approved">
				<!--- types object with approved status --->
				<cfset thisStatusLabel = "<span class='label label-info'>#application.rb.getResource("constants.status.#stNav.status#@label",stNav.status)#</span>">

			<cfelse>
				<!--- object with other status --->
				<cfset thisStatusLabel = "<span class='label'>#application.rb.getResource("constants.status.#stNav.status#@label",stNav.status)#</span>">

			</cfif>


			<cfset stFolderRow = structNew()>
			<cfset stFolderRow["objectid"] = stNav.objectid>
			<cfset stFolderRow["typename"] = stNav.typename>
			<cfset stFolderRow["class"] = thisClass>
			<cfset stFolderRow["nlevel"] = qTree.nlevel>
			<cfset stFolderRow["nodetype"] = "folder">
			<cfset stFolderRow["parentid"] = qTree.parentid>
			<cfset stFolderRow["label"] = stNav.label>
			<cfset stFolderRow["datetimelastupdated"] = "#lsDateFormat(stNav.datetimelastupdated)# #lsTimeFormat(stNav.datetimelastupdated)#">
			<cfset stFolderRow["prettydatetimelastupdated"] = application.fapi.prettyDate(stNav.datetimelastupdated)>
			<cfset stFolderRow["indentlevel"] = navIndentLevel>
			<cfset stFolderRow["spacer"] = repeatString('<i class="fc-icon-spacer"></i>', navIndentLevel+1)>
			<cfset stFolderRow["statuslabel"] = thisStatusLabel>
			<cfset stFolderRow["locked"] = false>
			<cfset stFolderRow["nodeicon"] = thisNodeIcon>
			<cfset stFolderRow["editURL"] = "#application.url.webtop#/edittabEdit.cfm?typename=#stNav.typename#&objectid=#stNav.objectid#">
			<cfset stFolderRow["previewURL"] = application.fapi.getLink(typename="dmNavigation", objectid=stNav.objectid, urlparameters="flushcache=1&showdraft=1")>


			<cfif stParam.responsetype eq "json">

				<cfset arrayAppend(stResponse["rows"], stFolderRow)>

			<cfelse>

				<cfoutput>
					<tr class="#stFolderRow["class"]#" data-objectid="#stFolderRow["objectid"]#" data-nlevel="#stFolderRow["nlevel"]#" data-indentlevel="#stFolderRow["indentlevel"]#" data-nodetype="#stFolderRow["nodetype"]#" data-parentid="#stFolderRow["parentid"]#">
						<td class="fc-hidden-compact"><input type="checkbox" class="checkbox"></td>
						<td class="objectadmin-actions">
							<button class="btn fc-btn-overview fc-hidden-compact fc-tooltip" onclick="$fc.objectAdminAction('#stFolderRow["label"]#', '#stFolderRow["overviewURL"]#'); return false;" title="" type="button" data-original-title="Object Overview"><i class="icon-th only-icon"></i></button>
							<button class="btn btn-edit fc-btn-edit fc-hidden-compact" type="button" onclick="$fc.objectAdminAction('#stFolderRow["label"]#', '#stFolderRow["editURL"]#', { onHidden: function(){ reloadTreeBranch('#stFolderRow["objectid"]#'); } }); return false;"><i class="icon-pencil"></i> Edit</button>
							<a href="#stFolderRow["previewURL"]#" class="btn fc-btn-preview fc-tooltip" title="" data-original-title="Preview"><i class="icon-eye-open only-icon"></i></a>

	<div class="btn-group"> 
		<button data-toggle="dropdown" class="btn dropdown-toggle" type="button"><i class="icon-caret-down only-icon"></i></button>
		<div class="dropdown-menu">
			<li class="fc-visible-compact"><a href="##" class="fc-btn-overview"><i class="icon-th icon-fixed-width"></i> Overview</a></li>
			<li class="fc-visible-compact"><a href="##" class="fc-btn-edit"><i class="icon-pencil icon-fixed-width"></i> Edit</a></li>
			<li class="fc-visible-compact"><a href="##" class="fc-btn-preview"><i class="icon-eye-open icon-fixed-width"></i> Preview</a></li>
			<li class="divider fc-visible-compact"></li>
			<li><a href="##" class="fc-add" onclick="$fc.objectAdminAction('Add Page', '#stFolderRow["createURL"]#', { onHidden: function(){ reloadTreeBranch('#stFolderRow["objectid"]#'); } }); return false;"><i class="icon-plus icon-fixed-width"></i> Add Page</a></li>
			<li><a href="##" class="fc-zoom"><i class="icon-zoom-in icon-fixed-width"></i> Zoom</a></li>

			<li class="divider"></li>
			<li><a href="##" class=""><i class="icon-trash icon-fixed-width"></i> Delete</a></li>

		</div>
	</div>



						</td>
						<td class="fc-tree-title fc-nowrap">#stFolderRow["spacer"]#<a class="fc-treestate-toggle" href="##"><i class="fc-icon-treestate"></i></a>#thisNodeIcon# <span>#stFolderRow["label"]#</span></td>
						<td class="fc-nowrap-ellipsis fc-visible-compact">#stFolderRow["previewURL"]#</td>
						<td class="fc-hidden-compact">#stFolderRow["statuslabel"]#</td>
						<td class="fc-hidden-compact" title="#stFolderRow["datetimelastupdated"]#">#stFolderRow["prettydatetimelastupdated"]#</td>
					</tr>
				</cfoutput>
			</cfif>

		</cfif>



		<cfloop from="1" to="#arrayLen(aLeafNodes)#" index="i">

			<cfset stLeafNode = aLeafNodes[i]>
			<cfset stLeafNode.bHasVersion = false>
			<cfparam name="stLeafNode.status" default="">
			<cfparam name="stLeafNode.locked" default="false">

			<!--- check for a versioned object of this leaf node --->
			<cfif structKeyExists(stLeafNode, "versionid") AND structKeyExists(stLeafNode, "status")>
				<cfquery name="qVersionedObject" datasource="#application.dsn#" >
					SELECT objectid,status,datetimelastupdated 
					FROM #application.dbowner##stLeafNode.typename# 
					WHERE versionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stLeafNode.objectid#">
				</cfquery>
				<cfif qVersionedObject.recordCount eq 1>
					<cfset stLeafNode.bHasVersion = true>
					<cfset stLeafNode.versionObjectid = qVersionedObject.objectID>
					<cfset stLeafNode.versionStatus = qVersionedObject.status>
					<cfset stLeafNode.versionDatetimelastupdated = qVersionedObject.datetimelastupdated>
				</cfif>
			</cfif>


			<!--- leaf nodes are indented 2 "spaces" deeper than nav nodes (one for the expander icon, one for the extra level of indentation) --->
			<cfset leafIndentLevel = navIndentLevel + 3>

			<cfset thisClass = "fc-treestate-hidden">
			<!--- if the parent nav node is expanded then the leaf will be visible --->
			<cfif bRootNode OR bExpanded>
				<cfset thisClass = "fc-treestate-visible">					
			</cfif>
			<!--- if the branch is loaded collapsed OR there is an unexpanded ancesotr then the leaf will be hidden --->
			<cfif url.loadCollapsed OR bUnexpandedAncestor>
				<cfset thisClass = "fc-treestate-hidden">
			</cfif>


			<!--- vary the status labels, icon, and edit URL by the object status --->
			<cfset thisStatusLabel = "">
			<cfset thisLeafIcon = "<span class='icon-stack'><i class='icon-file'></i></span>">
			<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?typename=#stLeafNode.typename#&objectid=#stLeafNode.objectid#">
			<cfif stLeafNode.bHasVersion>
				<!--- versioned object with multiple records --->
				<cfset thisStatusLabel = "<span class='label label-warning'>#application.rb.getResource("constants.status.#stLeafNode.versionStatus#@label",stLeafNode.versionStatus)#</span> + <span class='label label-info'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
				<cfset thisLeafIcon = "<span class='icon-stack'><i class='icon-file'></i><i class='icon-pencil'></i></span>">
				<cfset thisEditURL = "#application.url.webtop#/edittabEdit.cfm?typename=#stLeafNode.typename#&objectid=#stLeafNode.versionObjectid#">

			<cfelseif stLeafNode.status eq "draft">
				<!--- types object with draft status --->
				<cfset thisStatusLabel = "<span class='label label-warning'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
				<cfset thisLeafIcon = "<span class='icon-stack'><i class='icon-file'></i><i class='icon-pencil'></i></span>">

			<cfelseif stLeafNode.status eq "approved">
				<!--- types object with approved status --->
				<cfset thisStatusLabel = "<span class='label label-info'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
				
				<cfif structKeyExists(stLeafNode, "versionid") AND stLeafNode.status eq "approved">
					<!--- versioned object with approved only --->
					<cfset thisEditURL = "#application.url.webtop#/navajo/createDraftObject.cfm?typename=#stLeafNode.typename#&objectid=#stLeafNode.objectid#">
				</cfif>

			<cfelse>
				<!--- object with other status --->
				<cfset thisStatusLabel = "<span class='label'>#application.rb.getResource("constants.status.#stLeafNode.status#@label",stLeafNode.status)#</span>">
			</cfif>


			<!--- newest updated date --->
			<cfset lastupdated = stLeafNode.datetimelastupdated>
			<cfif stLeafNode.bHasVersion AND isValid("date", stLeafNode.versionDatetimelastupdated)>
				<cfset lastupdated = stLeafNode.versionDatetimelastupdated>
			</cfif>


			<cfset stLeafRow = structNew()>
			<cfset stLeafRow["objectid"] = stLeafNode.objectid>
			<cfset stLeafRow["typename"] = stLeafNode.typename>
			<cfset stLeafRow["class"] = thisClass>
			<cfset stLeafRow["nlevel"] = qTree.nlevel + 1>
			<cfset stLeafRow["nodetype"] = "leaf">
			<cfset stLeafRow["parentid"] = stNav.objectid>
			<cfset stLeafRow["label"] = stLeafNode.label>
			<cfset stLeafRow["datetimelastupdated"] = "#lsDateFormat(lastupdated)# #lsTimeFormat(lastupdated)#">
			<cfset stLeafRow["prettydatetimelastupdated"] = application.fapi.prettyDate(stLeafNode.datetimelastupdated)>
			<cfset stLeafRow["indentlevel"] = leafIndentLevel>
			<cfset stLeafRow["spacer"] = repeatString('<i class="fc-icon-spacer"></i>', leafIndentLevel)>
			<cfset stLeafRow["statuslabel"] = thisStatusLabel>
			<cfset stLeafRow["locked"] = stLeafNode.locked>
			<cfset stLeafRow["nodeicon"] = thisLeafIcon>
			<cfset stLeafRow["editURL"] = thisEditURL>
			<cfset stLeafRow["previewURL"] = application.fapi.getLink(typename=stLeafNode.typename, objectid=stLeafNode.objectid, urlparameters="flushcache=1&showdraft=1")>


			<cfif stParam.responsetype eq "json">

				<cfset arrayAppend(stResponse["rows"], stLeafRow)>

			<cfelse>

				<cfoutput>
					<tr class="#stLeafRow["class"]#" data-objectid="#stLeafRow["objectid"]#" data-nlevel="#stLeafRow["nlevel"]#" data-nodetype="#stLeafRow["nodetype"]#" data-parentid="#stLeafRow["parentid"]#">
						<td class="fc-hidden-compact"><input type="checkbox" class="checkbox"></td>
						<td class="objectadmin-actions">
							<button class="btn fc-btn-overview fc-hidden-compact fc-tooltip" onclick="$fc.objectAdminAction('#stLeafRow["label"]#', '#stLeafRow["overviewURL"]#'); return false;" title="" type="button" data-original-title="Object Overview"><i class="icon-th only-icon"></i></button>
							<button class="btn btn-edit fc-btn-edit fc-hidden-compact" type="button" onclick="$fc.objectAdminAction('#stLeafRow["label"]#', '#stLeafRow["editURL"]#'); return false;"><i class="icon-pencil"></i> Edit</button>
							<a href="#stLeafRow["previewURL"]#" class="btn fc-btn-preview fc-tooltip" title="" data-original-title="Preview"><i class="icon-eye-open only-icon"></i></a>

	<div class="btn-group"> 
		<button data-toggle="dropdown" class="btn dropdown-toggle" type="button"><i class="icon-caret-down only-icon"></i></button>
		<div class="dropdown-menu">
			<li class="fc-visible-compact"><a href="##" class="fc-btn-overview"><i class="icon-th icon-fixed-width"></i> Overview</a></li>
			<li class="fc-visible-compact"><a href="##" class="fc-btn-edit"><i class="icon-pencil icon-fixed-width"></i> Edit</a></li>
			<li class="fc-visible-compact"><a href="##" class="fc-btn-preview"><i class="icon-eye-open icon-fixed-width"></i> Preview</a></li>
			<li class="divider fc-visible-compact"></li>
			<li><a href="##" class=""><i class="icon-trash icon-fixed-width"></i> Delete</a></li>

		</div>
	</div>
						</td>
						<td class="fc-tree-title fc-nowrap">#stLeafRow["spacer"]##stLeafRow["nodeicon"]# #stLeafRow["label"]#</td>
						<td class="fc-nowrap-ellipsis fc-visible-compact">#stLeafRow["previewURL"]#</td>
						<td class="fc-hidden-compact">#stLeafRow["statuslabel"]#</td>
						<td class="fc-hidden-compact" title="#stLeafRow["datetimelastupdated"]#">#stLeafRow["prettydatetimelastupdated"]#</td>
					</tr>
				</cfoutput>

			</cfif>

		</cfloop>



	</cfloop>

</cfsavecontent>

<!--- output response --->
<cfset out = html>

<cfif stParam.responsetype eq "json">
	<cfset stResponse["success"] = true>
	<cfif request.mode.ajax>
		<cfcontent reset="true" type="application/json">		
	</cfif>
	<cfset out = serializeJSON(stResponse)>
</cfif>

<cfoutput>#out#</cfoutput>


<cfsetting enablecfoutputonly="false">