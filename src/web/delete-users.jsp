<%@ page import="java.net.MalformedURLException,
                 java.util.*,
                 org.dom4j.DocumentException,
                 org.tttalk.openfire.plugin.TTTalkUserBatchPlugin,org.jivesoftware.openfire.XMPPServer,org.jivesoftware.util.ParamUtils"
%>

<%
	boolean deleteUsers = request.getParameter("data") != null;
   
    TTTalkUserBatchPlugin plugin = (TTTalkUserBatchPlugin) XMPPServer.getInstance().getPluginManager().getPlugin("tttalk.userbatch");
   
    Map<String, String> errors = new HashMap<String, String>();
    if (deleteUsers) {
    	String data = request.getParameter("data");
    	if (data.trim().length() == 0){
    		errors.put("emptyData", "emptyData");
    	}else{
    		plugin.deleteUsers(data);        	
            response.sendRedirect("delete-users.jsp?success=true");
            return;            
    	}        
	} 
%>

<html>
    <head>
        <title>Delete User Accounts</title>
        <meta name="pageID" content="tttalk-delete"/>
    </head>
    <style>
	    ::-webkit-input-placeholder::before {
		  content: "username_1\000Ausername_2\000Ausername_3";
		}
		
		::-moz-placeholder::before {
		  content: "username_1\000Ausername_2\000Ausername_3";
		}
		
		:-ms-input-placeholder::before {
		  content: "username_1\000Ausername_2\000Ausername_3";
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
               Please input username list.<br>
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
            <td class="jive-icon-label">Users deleted successfully.</td>
        </tr>
        </tbody>
    </table>
    </div>
    <br>

<% } %>

<form action="delete-users.jsp?deleteUsers" method="post" >

<div class="jive-contentBoxHeader">Delete</div>
<div class="jive-contentBox">
    <textarea name="data" rows="10" style="width:50%" placeholder=" "></textarea>
</div>
<input type="submit" value="Delete">

</form>

</body>
</html>

