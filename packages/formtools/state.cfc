<cfcomponent name="state" displayname="State" hint="Field containing a state or province" extends="farcry.core.packages.formtools.field">
	
	<cfprocessingdirective pageencoding="utf-8" />
		
	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
	
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qCommon = "" />
		<cfset var qAll = "" />
		<cfset var qCountries = "" />
		<cfset var thisprop = "" />
		
		<cfparam name="arguments.stMetadata.ftCountries" default="" /><!--- Defaults to all --->
		<cfparam name="arguments.stMetadata.ftValue" default="name" /><!--- "code" | "fullcode" | "name" --->
		<cfparam name="arguments.stMetadata.ftDropdownFirstItem" default="" />
		
		<cfif structkeyexists(arguments.stMetadata,"ftWatch") and len(arguments.stMetadata.ftWatch)>
			<cfset arguments.stMetadata.ftCountries = arguments.stObject[listfirst(arguments.stMetadata.ftWatch)] />
		</cfif>
		
		<cfset qAll = getStates(arguments.stMetadata.ftCountries) />
		<cfquery dbtype="query" name="qCountries">
			select distinct countryname from qAll
		</cfquery>
		
		<cfif qAll.recordcount>
			<cfsavecontent variable="html">
				<cfoutput>
					<select name="#arguments.fieldname#" id="#arguments.fieldname#" class="selectInput #arguments.stMetadata.ftclass# #arguments.stMetadata.ftValidation#"  style="#arguments.stMetadata.ftstyle#">
				</cfoutput>
				<cfif len(arguments.stMetadata.ftDropdownFirstItem)>
					<cfoutput><option value="">#arguments.stMetadata.ftDropdownFirstItem#</option></cfoutput>
				</cfif>
				<cfoutput query="qAll" group="countryname">
					
					<cfif qCountries.recordcount gt 1><optgroup label="#qAll.countryname[qAll.currentrow]#"></cfif>
					
					<cfoutput><option value="#qAll[arguments.stMetadata.ftValue][qAll.currentrow]#" <cfif qAll[arguments.stMetadata.ftValue][qAll.currentrow] EQ arguments.stMetadata.value>selected='selected'</cfif>>#qAll.name[qAll.currentrow]#</option></cfoutput>
				
					<cfif qCountries.recordcount gt 1></optgroup></cfif>
				</cfoutput>
				
				<cfoutput>
					</select>
				</cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfset html = "N/A<input type='hidden' name='#arguments.fieldname#' value='N/A' />" />
		</cfif>
		
		<cfreturn html />
	</cffunction>

	<cffunction name="getStates" returntype="query" output="false" access="public" hint="Returns states and acronyms">
		<cfargument name="countries" type="string" required="false" hint="Including this argument restricts the states to certain countries or country codes" />
		
		<cfset var q = querynew("countrycode,countryname,code,fullcode,name") />
		
		<cfif not structkeyexists(this,"qStates")>
			<!--- Australia --->
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ACT") /><cfset querysetcell(q,"name","Australian Capital Territory") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NSW") /><cfset querysetcell(q,"name","New South Wales") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NT") /><cfset querysetcell(q,"name","Northern Territory") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","QLD") /><cfset querysetcell(q,"name","Queensland") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SA") /><cfset querysetcell(q,"name","South Australia") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TAS") /><cfset querysetcell(q,"name","Tasmania") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VIC") /><cfset querysetcell(q,"name","Victoria") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","WA") /><cfset querysetcell(q,"name","Western Australia") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			
			<!--- New Zealand --->
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Auckland") /><cfset querysetcell(q,"name","Auckland") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Bay of Plenty") /><cfset querysetcell(q,"name","Bay of Plenty") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Canterbury") /><cfset querysetcell(q,"name","Canterbury") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Gisborne") /><cfset querysetcell(q,"name","Gisborne") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Hawke's Bay") /><cfset querysetcell(q,"name","Hawke's Bay") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Manawatu-Wanganui") /><cfset querysetcell(q,"name","Manawatu-Wanganui") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Marlborough") /><cfset querysetcell(q,"name","Marlborough") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Nelson") /><cfset querysetcell(q,"name","Nelson") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Northland") /><cfset querysetcell(q,"name","Northland") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Otago") /><cfset querysetcell(q,"name","Otago") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Southland") /><cfset querysetcell(q,"name","Southland") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Taranaki") /><cfset querysetcell(q,"name","Taranaki") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Tasman") /><cfset querysetcell(q,"name","Tasman") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Waikato") /><cfset querysetcell(q,"name","Waikato") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","Wellington") /><cfset querysetcell(q,"name","Wellington") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","West Coast") /><cfset querysetcell(q,"name","West Coast") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			
			<!--- Netherlands --->
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","DR") /><cfset querysetcell(q,"name","Drenthe") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","FL") /><cfset querysetcell(q,"name","Flevoland") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","FR") /><cfset querysetcell(q,"name","Friesland") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GE") /><cfset querysetcell(q,"name","Gelderland") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GR") /><cfset querysetcell(q,"name","Groningen") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LI") /><cfset querysetcell(q,"name","Limburg") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NB") /><cfset querysetcell(q,"name","Noord Brabant") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NH") /><cfset querysetcell(q,"name","Noord Holland") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","OV") /><cfset querysetcell(q,"name","Overijssel") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","UT") /><cfset querysetcell(q,"name","Utrecht") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ZE") /><cfset querysetcell(q,"name","Zeeland") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ZH") /><cfset querysetcell(q,"name","Zuid Holland") /><cfset querysetcell(q,"countrycode","NL") /><cfset querysetcell(q,"countryname","Netherlands") /> 

			<!--- Norway --->
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","02") /><cfset querysetcell(q,"name","Akershus") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","09") /><cfset querysetcell(q,"name","Aust-Agder") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","06") /><cfset querysetcell(q,"name","Buskerud") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","20") /><cfset querysetcell(q,"name","Finnmark") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","04") /><cfset querysetcell(q,"name","Hedmark") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","12") /><cfset querysetcell(q,"name","Hordaland") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","15") /><cfset querysetcell(q,"name","Møre og Romsdal") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","18") /><cfset querysetcell(q,"name","Nordland") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","17") /><cfset querysetcell(q,"name","Nord-Trøndelag") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","05") /><cfset querysetcell(q,"name","Oppland") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","03") /><cfset querysetcell(q,"name","Oslo") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","11") /><cfset querysetcell(q,"name","Rogaland") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","14") /><cfset querysetcell(q,"name","Sogn og Fjordane") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","16") /><cfset querysetcell(q,"name","Sør-Trøndelag") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","08") /><cfset querysetcell(q,"name","Telemark") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","19") /><cfset querysetcell(q,"name","Troms") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","10") /><cfset querysetcell(q,"name","Vest-Agder") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","07") /><cfset querysetcell(q,"name","Vestfold") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","01") /><cfset querysetcell(q,"name","Østfold") /><cfset querysetcell(q,"countrycode","NO") /><cfset querysetcell(q,"countryname","Norway") />
			
			<!--- Deutschland (Germany) - ISO 3166-2:DE - !!! WITH HIGH ASCII CHARS !!! --->
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BW") /><cfset querysetcell(q,"name","Baden-Württemberg") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BY") /><cfset querysetcell(q,"name","Bayern") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BE") /><cfset querysetcell(q,"name","Berlin") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BR") /><cfset querysetcell(q,"name","Brandenburg") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HB") /><cfset querysetcell(q,"name","Bremen") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HH") /><cfset querysetcell(q,"name","Hamburg") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HE") /><cfset querysetcell(q,"name","Hessen") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MV") /><cfset querysetcell(q,"name","Mecklenburg-Vorpommern") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NI") /><cfset querysetcell(q,"name","Niedersachsen") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NW") /><cfset querysetcell(q,"name","Nordrhein-Westfalen") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","RP") /><cfset querysetcell(q,"name","Rheinland-Pfalz") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SL") /><cfset querysetcell(q,"name","Saarland") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SN") /><cfset querysetcell(q,"name","Sachsen") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ST") /><cfset querysetcell(q,"name","Sachsen-Anhalt") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SH") /><cfset querysetcell(q,"name","Schleswig-Holstein") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TH") /><cfset querysetcell(q,"name","Thüringen") /><cfset querysetcell(q,"countrycode","DE") /><cfset querysetcell(q,"countryname","Deutschland") />
			
			<!--- Belgium --->
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","WV") /><cfset querysetcell(q,"name","West-Vlaanderen") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","OV") /><cfset querysetcell(q,"name","Oost-Vlaanderen") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AN") /><cfset querysetcell(q,"name","Antwerpen") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LI") /><cfset querysetcell(q,"name","Limburg") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VB") /><cfset querysetcell(q,"name","Vlaams-Brabant") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BR") /><cfset querysetcell(q,"name","Brussel") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BW") /><cfset querysetcell(q,"name","Waals-Brabant") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HA") /><cfset querysetcell(q,"name","Henegouwen") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NA") /><cfset querysetcell(q,"name","Namen") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LG") /><cfset querysetcell(q,"name","Luik") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LU") /><cfset querysetcell(q,"name","Luxemburg") /><cfset querysetcell(q,"countrycode","BE") /><cfset querysetcell(q,"countryname","Belgium") />
			
			<cfset this.qStates = q />
		</cfif>
		
		<cfquery dbtype="query" name="q">
			select		countrycode,countryname,code,name,countrycode + '-' + code as fullcode
			from		this.qStates
			<cfif structkeyexists(arguments,"countries") and len(arguments.countries)>
				where	countrycode in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.countries#">)
						OR countryname in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.countries#">)
			</cfif>
			order by	countryname,name
		</cfquery>
		
		<cfreturn q />
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = arguments.stMetadata.value />
		<cfset var q = "" />
		
		<cfif structkeyexists(arguments.stMetadata,"ftValue") and arguments.stMetadata.ftValue eq "code">
			<cfset q = getCountries(arguments.stMetadata.value) />
			<cfset html = q.name[1] />
		</cfif>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = passed(value=stFieldPost.Value) />
		
		<cfif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required") AND NOT len(stFieldPost.Value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is a required field.") />
		</cfif>
	
		<cfreturn stResult />
	</cffunction>
	
</cfcomponent>