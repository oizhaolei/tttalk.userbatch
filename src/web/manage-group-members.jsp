<%@ page import="java.net.MalformedURLException,
                 java.util.*,
                 org.apache.commons.fileupload.DiskFileUpload,
                 org.apache.commons.fileupload.FileItem,
                 org.tttalk.openfire.plugin.TTTalkUserBatchPlugin,
                 org.jivesoftware.openfire.XMPPServer,
                 org.jivesoftware.util.ParamUtils"
%>

<%
	boolean manageGroupMemebers = request.getParameter("manageGroupMemebers") != null;
   
    TTTalkUserBatchPlugin plugin = (TTTalkUserBatchPlugin) XMPPServer.getInstance().getPluginManager().getPlugin("tttalk.userbatch");
   
    Map<String, String> errors = new HashMap<String, String>();
    if (manageGroupMemebers) {
    	String data = request.getParameter("data");
    	if (data.trim().length() == 0){
    		errors.put("emptyData", "emptyData");
    	}else{
			plugin.manageGroupMemebers(data);
    	}        
	}
%>

<html>
    <head>
        <title>Manage TTTalk Group Members</title>
        <meta name="pageID" content="tttalk-group-members"/>
    </head>
    <style>
	    ::-webkit-input-placeholder::before {
		  content: "groupname_1\000Agroupname_2\000Agroupname_3";
		}
		
		::-moz-placeholder::before {
		  content: "groupname_1\000Agroupname_2\000Agroupname_3";
		}
		
		:-ms-input-placeholder::before {
		  content: "groupname_1\000Agroupname_2\000Agroupname_3";
		}
    </style>
    <body>

<% if (errors.size() > 0) { %>

    <div class="jive-error">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr>
            <td class="jive-icon"><img src="images/error-16x16.gif" width="16" height="16" border="0"></td>
            <td class="jive-icon-label">
            <% if (errors.containsKey("emptyData")) { %>
               Please input groupname list.<br>
            <% } %>
            </td>
        </tr>
        </tbody>
    </table>
    </div>
    <br>

<% } else if (ParamUtils.getBooleanParameter(request, "success")) { %>

    <div class="jive-success">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr>
            <td class="jive-icon"><img src="images/success-16x16.gif" width="16" height="16" border="0"></td>
            <td class="jive-icon-label">All groups added successfully.</td>
        </tr>
        </tbody>
    </table>
    </div>
    <br>

<% } %>

<form action="manage-group-members.jsp?manageGroupMemebers=true" method="post" >

<div class="jive-contentBoxHeader">Group Members</div>
<div class="jive-contentBox">
    <textarea name="data" rows="10" style="width:50%" placeholder=" "></textarea>
</div>
<input type="submit" value="Create">

</form>


</body>
</html>

