package org.tttalk.openfire.plugin;

import gnu.inet.encoding.Stringprep;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.fileupload.FileItem;
import org.dom4j.DocumentException;
import org.jivesoftware.openfire.XMPPServer;
import org.jivesoftware.openfire.container.Plugin;
import org.jivesoftware.openfire.container.PluginManager;
import org.jivesoftware.openfire.group.Group;
import org.jivesoftware.openfire.group.GroupManager;
import org.jivesoftware.openfire.user.User;
import org.jivesoftware.openfire.user.UserManager;
import org.jivesoftware.openfire.user.UserProvider;
import org.jivesoftware.util.WebManager;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.packet.JID;

public class TTTalkUserBatchPlugin implements Plugin {

	private static final Logger log = LoggerFactory
			.getLogger(TTTalkUserBatchPlugin.class);

	private UserManager userManager;
	private GroupManager groupManager;
	private UserProvider provider;

	private String domain;

	public TTTalkUserBatchPlugin() {
		userManager = XMPPServer.getInstance().getUserManager();
		WebManager wm = new WebManager();
		wm.getGroupManager();
		groupManager = GroupManager.getInstance();
		provider = UserManager.getUserProvider();
		domain = XMPPServer.getInstance().getServerInfo().getXMPPDomain();
	}

	@Override
	public void initializePlugin(PluginManager manager, File pluginDirectory) {
	}

	@Override
	public void destroyPlugin() {
		userManager = null;
		provider = null;
	}

	/**
	 * Convenience method that returns true if this UserProvider is read-only.
	 *
	 * @return true if the user provider is read-only.
	 */
	public boolean isUserProviderReadOnly() {
		return provider.isReadOnly();
	}

	public List<String> createUsers(String userData) {
		List<String> invalidUsers = new ArrayList<String>();

		String[] lines = userData.split("\n");

		int create = 0;
		int error = 0;

		for (int i = 0; i < lines.length; i++) {
			String[] temp = lines[i].split(",");
			String userName = temp[0].trim();
			String password = temp[1].trim();

			if ((userName != null) && (password != null)) {
				try {
					userName = Stringprep.nodeprep(userName);

					if (!isUserProviderReadOnly()) {
						userManager.createUser(userName, password, null, null);
						log.info("createUser: " + userName + "," + password);
					}

					// Check to see user exists before adding their roster, this
					// is for read-only user providers.
					userManager.getUser(userName);
					create++;
				} catch (Exception e) {
					error++;
					log.error(e.getMessage());
					invalidUsers.add(userName);
				}
			}
		}
		log.info("createUsers create: " + create + ", error:" + error);

		return invalidUsers;
	}

	public List<String> importUserData(FileItem file) throws DocumentException,
			IOException {
		List<String> invalidUsers = new ArrayList<String>();
		BufferedReader in = new BufferedReader(new InputStreamReader(
				file.getInputStream()));
		String line = null;
		int create = 0;
		int error = 0;
		while ((line = in.readLine()) != null) {
			log.info("readLine: " + line);
			String[] temp = line.split(",");
			if (temp.length != 2)
				continue;
			String userName = temp[0].trim();
			String password = temp[1].trim();
			if ((userName == null) || (password == null))
				continue;

			try {
				userName = Stringprep.nodeprep(userName);

				if (!isUserProviderReadOnly()) {
					userManager.createUser(userName, password, null, null);
					log.info("createUser: " + userName + "," + password);
				}

				// Check to see user exists before adding their roster, this
				// is for read-only user providers.
				userManager.getUser(userName);
				create++;
			} catch (Exception e) {
				error++;
				log.error(e.getMessage());
				invalidUsers.add(userName);
			}
		}
		log.info("createUsers create: " + create + ", error:" + error);

		return invalidUsers;
	}

	public void deleteUsers(String str) {
		String[] usernames = str.split("\n");

		// RosterManager rosterManager = server.getRosterManager();
		log.info("Deleting users accounts: " + usernames.length);
		int delete = 0;
		int error = 0;
		for (String username : usernames) {
			try {
				username = username.trim();
				User user = userManager.getUser(username);

				// deleteRosters(user, rosterManager);
				userManager.deleteUser(user);
				log.info("deleteUser: " + username);
				delete++;
			} catch (Exception e) {
				error++;
				log.error(e.getMessage());
			}
		}
		log.info("deleteUsers deleted: " + delete + ", error:" + error);
	}

	public List<String> createGroups(String groupData) {
		List<String> invalidGroups = new ArrayList<String>();

		String[] lines = groupData.split("\n");

		int create = 0;
		int error = 0;

		for (int i = 0; i < lines.length; i++) {
			String line = lines[i];
			String groupName = line.trim();

			if ((groupName != null)) {
				try {
					groupName = Stringprep.nodeprep(groupName);

					// Check to see user exists before adding their roster, this
					// is for read-only user providers.
					groupManager.createGroup(groupName);
					create++;
				} catch (Exception e) {
					error++;
					log.error(e.getMessage());
					invalidGroups.add(groupName);
				}
			}
		}
		log.info("createUsers create: " + create + ", error:" + error);

		return invalidGroups;
	}

	public List<String> importGroupData(FileItem file)
			throws DocumentException, IOException {
		// TODO
		return null;
	}

	public void manageGroupMemebers(String str) throws JSONException {
		JSONArray ja = new JSONArray(str);
		for (int i = 0; i < ja.length(); i++) {
			JSONObject gjo = ja.getJSONObject(i);
			String groupname = gjo.getString("group");
			JSONArray mja = gjo.getJSONArray("members");
			List<String> members = new ArrayList<>();
			for (int j = 0; j < mja.length(); j++) {
				String username = mja.getString(j);
				members.add(username);
			}
			// groupname & members
			try {
				Group group = groupManager.getGroup(groupname);
				group.getMembers().clear();
				for (String username : members) {
					group.getMembers().add(
							new JID(username + '@' + domain + '/' + "tttalk"));
				}
			} catch (Exception e) {
				log.error(e.getMessage());
			}
		}
	}

	public void deleteGroups(String str) {
		String[] groupnames = str.split("\n");

		// RosterManager rosterManager = server.getRosterManager();
		log.info("Deleting groups accounts: " + groupnames.length);
		int delete = 0;
		int error = 0;
		for (String groupname : groupnames) {
			try {
				groupname = groupname.trim();
				Group group = groupManager.getGroup(groupname);

				// deleteRosters(group, rosterManager);
				groupManager.deleteGroup(group);
				log.info("deleteGroup: " + groupname);
				delete++;
			} catch (Exception e) {
				error++;
				log.error(e.getMessage());
			}
		}
		log.info("deleteGroups deleted: " + delete + ", error:" + error);
	}

}
