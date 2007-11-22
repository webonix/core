<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/verityOptimise.cfm,v 1.11 2005/08/16 05:53:23 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 05:53:23 $
$Name: milestone_3-0-1 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: Optimise all Verity collections for the active application. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header title="#application.adminBundle[session.dmProfile.locale].buildVerityIndices#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminSearchTab">
	<!--------------------------------------------------------------------
	Optimisation Routine For CFMX 
	--------------------------------------------------------------------->
	<cfoutput><h3>Optimising Collections</h3></cfoutput>
	
	<!--- get system Verity information ---> 
	<cfcollection action="LIST" name="qcollections">
	
	<!--- optimising collections --->
	<h3>Optimising Collections</h3>
	<cfloop query="qCollections">
		<cfif findNoCase(application.applicationname, qCollections.name)>
			<cftry>
				<cfset application.factory.oVerity.optimiseCollection(qCollections.name)>
				<cfoutput>#qCollections.name#: #application.adminBundle[session.dmProfile.locale].optimized#...<br /></cfoutput>
				<cfcatch><cfoutput>#qCollections.name#: #application.adminBundle[session.dmProfile.locale].errorOptimizing#<br /></cfoutput></cfcatch>
			</cftry>
			<cfflush>
		</cfif>
	</cfloop>
	
	<cfoutput><p><strong class="success fade" id="fader1">#application.adminBundle[session.dmProfile.locale].allDone#</strong></p></cfoutput>
</sec:CheckPermission error="true">

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">
