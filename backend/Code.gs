/**
 * Google Apps Script Backend for LinkedIn Auto Poster
 * 
 * Instructions:
 * 1. Set the APPS_SCRIPT_SECRET below (matches .env)
 * 2. Set LinkedIn credentials in Script Properties
 * 3. Deploy as Web App (Execute as: Me, Access: Anyone)
 * 4. Run setupTimeTrigger() once to enable automatic posting
 * 5. Run getLinkedInAuthUrl() to get OAuth URL for first-time setup
 */

const APPS_SCRIPT_SECRET = "SET_YOUR_SECRET_HERE"; // IMPORTANT: Update this and your Flutter .env

// LinkedIn API Configuration
const LINKEDIN_API_BASE = "https://api.linkedin.com/v2";
const LINKEDIN_AUTH_BASE = "https://www.linkedin.com/oauth/v2";

/**
 * Handles incoming POST requests from the Flutter app.
 */
function doPost(e) {
  try {
    const headers = e.postData.headers || {};
    const secret = headers["X-App-Secret"] || e.parameter.secret;

    if (secret !== APPS_SCRIPT_SECRET) {
      return response("Unauthorized", 401);
    }

    const data = JSON.parse(e.postData.contents);
    
    // Handle authentication requests
    if (data.action === 'getAuthUrl') {
      return response(getLinkedInAuthUrl());
    }
    
    if (data.action === 'testConnection') {
      return response(testLinkedInConnection());
    }
    
    // Handle batch posts
    if (data.action === 'batch' && data.posts) {
      return handleBatchPosts(data.posts);
    }
    
    // Handle single post
    const { topic, content, scheduledAt } = data;

    if (!content) {
      return response("Missing content", 400);
    }

    // Process the scheduling
    const result = schedulePostOnLinkedIn(content, scheduledAt);

    return response({
      status: "success",
      message: "Post scheduled on backend",
      topic: topic,
      linkedin_result: result
    });

  } catch (error) {
    console.error("Error in doPost:", error);
    return response({ status: "error", message: error.toString() }, 500);
  }
}

/**
 * Handle batch scheduling of multiple posts.
 */
function handleBatchPosts(posts) {
  const results = [];
  
  for (const post of posts) {
    const { topic, content, scheduledAt } = post;
    
    if (!content) {
      results.push({ topic, status: "error", message: "Missing content" });
      continue;
    }
    
    const result = schedulePostOnLinkedIn(content, scheduledAt);
    results.push({ topic, status: "success", linkedin_result: result });
  }
  
  return response({
    status: "success",
    message: `Processed ${results.length} posts`,
    results: results
  });
}

/**
 * Placeholder for the actual LinkedIn API call.
 * In a real production environment, you would use UrlFetchApp
 * with a stored OAuth2 token.
 */
function schedulePostOnLinkedIn(content, scheduledAt) {
  try {
    console.log(`📅 [LinkedIn] Scheduling post for: ${scheduledAt}`);
    console.log(`📝 [LinkedIn] Content: ${content.substring(0, 100)}...`);
    
    // Store the post for later processing by time trigger
    const postId = Utilities.getUuid();
    const post = {
      id: postId,
      content: content,
      scheduledAt: scheduledAt,
      status: 'scheduled',
      createdAt: new Date().toISOString()
    };
    
    // Get existing scheduled posts
    const existingPosts = getStoredPosts();
    existingPosts.push(post);
    
    // Store updated posts
    PropertiesService.getScriptProperties().setProperty('scheduled_posts', JSON.stringify(existingPosts));
    
    console.log(`✅ [LinkedIn] Post stored with ID: ${postId}`);
    
    return {
      scheduled: true,
      postId: postId,
      scheduledAt: scheduledAt,
      message: "Post stored and will be posted automatically at scheduled time"
    };
    
  } catch (error) {
    console.error(`❌ [LinkedIn] Error scheduling post: ${error}`);
    return {
      scheduled: false,
      error: error.toString()
    };
  }
}

/**
 * Get stored posts from Script Properties
 */
function getStoredPosts() {
  try {
    const postsJson = PropertiesService.getScriptProperties().getProperty('scheduled_posts');
    return postsJson ? JSON.parse(postsJson) : [];
  } catch (error) {
    console.error(`❌ [Storage] Error getting posts: ${error}`);
    return [];
  }
}

/**
 * Save posts to Script Properties
 */
function saveStoredPosts(posts) {
  try {
    PropertiesService.getScriptProperties().setProperty('scheduled_posts', JSON.stringify(posts));
    console.log(`💾 [Storage] Saved ${posts.length} posts`);
  } catch (error) {
    console.error(`❌ [Storage] Error saving posts: ${error}`);
  }
}

/**
 * TIME-BASED TRIGGER FUNCTIONS
 */

/**
 * Set up the time-based trigger (run this once manually)
 */
function setupTimeTrigger() {
  try {
    // Delete existing triggers first
    const triggers = ScriptApp.getProjectTriggers();
    triggers.forEach(trigger => {
      if (trigger.getHandlerFunction() === 'checkAndPostScheduledPosts') {
        ScriptApp.deleteTrigger(trigger);
      }
    });
    
    // Create new trigger to run every 5 minutes
    ScriptApp.newTrigger('checkAndPostScheduledPosts')
      .timeBased()
      .everyMinutes(5)
      .create();
      
    console.log('⏰ [Trigger] Time-based trigger set up successfully (every 5 minutes)');
    return { success: true, message: 'Time trigger created successfully' };
    
  } catch (error) {
    console.error(`❌ [Trigger] Error setting up trigger: ${error}`);
    return { success: false, error: error.toString() };
  }
}

/**
 * Check for posts that need to be posted (runs every 5 minutes)
 */
function checkAndPostScheduledPosts() {
  try {
    console.log('🔍 [Trigger] Checking for posts to publish...');
    
    const posts = getStoredPosts();
    const now = new Date();
    let postsProcessed = 0;
    
    console.log(`📊 [Trigger] Found ${posts.length} total posts`);
    
    for (let i = 0; i < posts.length; i++) {
      const post = posts[i];
      
      if (post.status !== 'scheduled') continue;
      
      const scheduledTime = new Date(post.scheduledAt);
      
      // Check if it's time to post (within 5 minutes of scheduled time)
      if (now >= scheduledTime) {
        console.log(`⏰ [Trigger] Time to post: ${post.id}`);
        
        const result = postToLinkedIn(post.content, post.id);
        
        if (result.success) {
          posts[i].status = 'posted';
          posts[i].postedAt = now.toISOString();
          posts[i].linkedinResult = result;
          postsProcessed++;
          console.log(`✅ [Trigger] Successfully posted: ${post.id}`);
        } else {
          posts[i].status = 'failed';
          posts[i].error = result.error;
          posts[i].failedAt = now.toISOString();
          console.log(`❌ [Trigger] Failed to post: ${post.id} - ${result.error}`);
        }
      }
    }
    
    // Save updated posts
    if (postsProcessed > 0) {
      saveStoredPosts(posts);
      console.log(`📝 [Trigger] Updated ${postsProcessed} posts`);
    }
    
    console.log(`✅ [Trigger] Check complete. Processed ${postsProcessed} posts.`);
    
  } catch (error) {
    console.error(`❌ [Trigger] Error in checkAndPostScheduledPosts: ${error}`);
  }
}

/**
 * LINKEDIN API INTEGRATION
 */

/**
 * Get LinkedIn credentials from Script Properties
 */
function getLinkedInCredentials() {
  const properties = PropertiesService.getScriptProperties();
  return {
    clientId: properties.getProperty('LINKEDIN_CLIENT_ID'),
    clientSecret: properties.getProperty('LINKEDIN_CLIENT_SECRET'),
    accessToken: properties.getProperty('LINKEDIN_ACCESS_TOKEN'),
    personId: properties.getProperty('LINKEDIN_PERSON_ID')
  };
}

/**
 * Get LinkedIn OAuth2 authorization URL
 */
function getLinkedInAuthUrl() {
  const credentials = getLinkedInCredentials();
  
  if (!credentials.clientId) {
    return { error: 'LinkedIn Client ID not set in Script Properties' };
  }
  
  // Use the script's web app URL as redirect URI
  const scriptId = ScriptApp.getScriptId();
  const redirectUri = encodeURIComponent(`https://script.google.com/macros/d/${scriptId}/usercallback`);
  const scope = encodeURIComponent('r_liteprofile w_member_social');
  const state = Utilities.getUuid();
  
  // Store state for verification
  PropertiesService.getScriptProperties().setProperty('oauth_state', state);
  
  const authUrl = `${LINKEDIN_AUTH_BASE}/authorization?` +
    `response_type=code&` +
    `client_id=${credentials.clientId}&` +
    `redirect_uri=${redirectUri}&` +
    `state=${state}&` +
    `scope=${scope}`;
    
  console.log('🔗 [OAuth] Authorization URL generated');
  return { authUrl: authUrl };
}

/**
 * Handle OAuth2 callback (set this as your redirect URI)
 */
function handleLinkedInCallback(code, state) {
  try {
    const storedState = PropertiesService.getScriptProperties().getProperty('oauth_state');
    
    if (state !== storedState) {
      throw new Error('Invalid state parameter');
    }
    
    const credentials = getLinkedInCredentials();
    const scriptId = ScriptApp.getScriptId();
    const redirectUri = `https://script.google.com/macros/d/${scriptId}/usercallback`;
    
    // Exchange code for access token
    const tokenResponse = UrlFetchApp.fetch(`${LINKEDIN_AUTH_BASE}/accessToken`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      payload: {
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: redirectUri,
        client_id: credentials.clientId,
        client_secret: credentials.clientSecret
      }
    });
    
    const tokenData = JSON.parse(tokenResponse.getContentText());
    
    if (tokenData.access_token) {
      // Store access token
      PropertiesService.getScriptProperties().setProperty('LINKEDIN_ACCESS_TOKEN', tokenData.access_token);
      
      // Get user profile to store person ID
      const profileResponse = UrlFetchApp.fetch(`${LINKEDIN_API_BASE}/people/~`, {
        headers: {
          'Authorization': `Bearer ${tokenData.access_token}`
        }
      });
      
      const profileData = JSON.parse(profileResponse.getContentText());
      PropertiesService.getScriptProperties().setProperty('LINKEDIN_PERSON_ID', profileData.id);
      
      console.log('✅ [OAuth] LinkedIn authentication successful');
      return { success: true, message: 'LinkedIn authentication successful' };
    } else {
      throw new Error('Failed to get access token');
    }
    
  } catch (error) {
    console.error(`❌ [OAuth] Authentication error: ${error}`);
    return { success: false, error: error.toString() };
  }
}

/**
 * Post content to LinkedIn
 */
function postToLinkedIn(content, postId) {
  try {
    const credentials = getLinkedInCredentials();
    
    if (!credentials.accessToken || !credentials.personId) {
      throw new Error('LinkedIn not authenticated. Run getLinkedInAuthUrl() first.');
    }
    
    console.log(`📤 [LinkedIn] Posting to LinkedIn: ${postId}`);
    
    const postData = {
      author: `urn:li:person:${credentials.personId}`,
      lifecycleState: 'PUBLISHED',
      specificContent: {
        'com.linkedin.ugc.ShareContent': {
          shareCommentary: {
            text: content
          },
          shareMediaCategory: 'NONE'
        }
      },
      visibility: {
        'com.linkedin.ugc.MemberNetworkVisibility': 'PUBLIC'
      }
    };
    
    const response = UrlFetchApp.fetch(`${LINKEDIN_API_BASE}/ugcPosts`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${credentials.accessToken}`,
        'Content-Type': 'application/json',
        'X-Restli-Protocol-Version': '2.0.0'
      },
      payload: JSON.stringify(postData)
    });
    
    const responseData = JSON.parse(response.getContentText());
    
    if (response.getResponseCode() === 201) {
      console.log(`✅ [LinkedIn] Post successful: ${responseData.id}`);
      return {
        success: true,
        linkedinPostId: responseData.id,
        postedAt: new Date().toISOString()
      };
    } else {
      throw new Error(`LinkedIn API error: ${response.getResponseCode()} - ${response.getContentText()}`);
    }
    
  } catch (error) {
    console.error(`❌ [LinkedIn] Posting error: ${error}`);
    return {
      success: false,
      error: error.toString()
    };
  }
}

/**
 * UTILITY FUNCTIONS
 */

/**
 * Get status of all scheduled posts
 */
function getPostsStatus() {
  const posts = getStoredPosts();
  const summary = {
    total: posts.length,
    scheduled: posts.filter(p => p.status === 'scheduled').length,
    posted: posts.filter(p => p.status === 'posted').length,
    failed: posts.filter(p => p.status === 'failed').length,
    posts: posts
  };
  
  console.log(`📊 [Status] Total: ${summary.total}, Scheduled: ${summary.scheduled}, Posted: ${summary.posted}, Failed: ${summary.failed}`);
  return summary;
}

/**
 * Clear all stored posts (use with caution)
 */
function clearAllPosts() {
  PropertiesService.getScriptProperties().deleteProperty('scheduled_posts');
  console.log('🗑️ [Storage] All posts cleared');
  return { success: true, message: 'All posts cleared' };
}

/**
 * Test LinkedIn connection
 */
function testLinkedInConnection() {
  const credentials = getLinkedInCredentials();
  
  if (!credentials.accessToken) {
    return { success: false, error: 'No access token. Please authenticate first.' };
  }
  
  try {
    const response = UrlFetchApp.fetch(`${LINKEDIN_API_BASE}/people/~`, {
      headers: {
        'Authorization': `Bearer ${credentials.accessToken}`
      }
    });
    
    if (response.getResponseCode() === 200) {
      const profile = JSON.parse(response.getContentText());
      return {
        success: true,
        profile: {
          id: profile.id,
          firstName: profile.localizedFirstName,
          lastName: profile.localizedLastName
        }
      };
    } else {
      return { success: false, error: `API error: ${response.getResponseCode()}` };
    }
    
  } catch (error) {
    return { success: false, error: error.toString() };
  }
}

function response(data, code = 200) {
  const output = typeof data === 'string' ? data : JSON.stringify(data);
  return ContentService.createTextOutput(output)
    .setMimeType(data === 'string' ? ContentService.MimeType.TEXT : ContentService.MimeType.JSON);
}
