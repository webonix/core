<cfsetting enablecfoutputonly="Yes">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header:  $
$Author:  $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
Sets html cache header parameters for web pages.

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> [attributes.days]: How many days to cache for
-> [attributes.hours]: How many hours to cache for
-> [attributes.minutes]: How many minutes to cache for
-> [attributes.seconds]: How many seconds to cache for
-> [url.CacheControlDebug]: Shows how long page is cached for if anything other than 0
--->

<!--- exit tag if its been closed, ie don't run twice --->
<cfif thistag.executionmode eq "end">
	<cfexit method="exittag" />
</cfif>

<!---
	Some firewalls strip off the CFHEADER information,
	some browsers don't support META tags,
	so it's best to include both CFHEADER and META
--->

<cfparam name="url.CacheControlDebug" default="0">

<cfset totalseconds = 0 />
<cfif isdefined("attributes.days")><cfset totalseconds = totalseconds + attributes.days * 86400 /></cfif>
<cfif isdefined("attributes.hours")><cfset totalseconds = totalseconds + attributes.hours * 3600 /></cfif>
<cfif isdefined("attributes.minutes")><cfset totalseconds = totalseconds + attributes.minutes * 60 /></cfif>
<cfif isdefined("attributes.seconds")><cfset totalseconds = totalseconds + attributes.seconds /></cfif>

<cfif totalseconds eq 0>
	<CFHEADER NAME="Expires" VALUE="Tue, 01 Jan 1985 00:00:01 GMT">
	<CFHEADER NAME="Pragma" VALUE="no-cache">
	<CFHEADER NAME="cache-control" VALUE="no-cache, no-store, must-revalidate">
	
	<cfoutput>
	<META HTTP-EQUIV="Expires" CONTENT="Tue, 01 Jan 1985 00:00:01 GMT" />
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache" />
	<META HTTP-EQUIV="cache-control" CONTENT="no-cache, no-store, must-revalidate" />
	</cfoutput>
	
	<cfif ( url.CacheControlDebug neq 0 )>
		<cfoutput>Page cached until: Page not cached</cfoutput>
	</cfif>
<cfelse>
	
	<cfif url.CacheControlDebug neq 0><cfoutput>Page cached for: #totalseconds# seconds</cfoutput></cfif>
	
	<CFHEADER NAME="Cache-Control" VALUE="max-age=#totalseconds#,s-maxage=#totalseconds#">
	<cfoutput><META HTTP-EQUIV="Cache-Control" CONTENT="max-age=#totalseconds#,s-maxage=#totalseconds#" /></cfoutput>
	
	<cfif ( url.CacheControlDebug neq 0 )>
		<cfoutput>Page cached for: #totalseconds# seconds</cfoutput>
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="No">
