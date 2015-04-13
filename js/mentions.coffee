---
---

activityToActionMap = {
    "like": "liked",
};

parseMention = (mention) ->
    {
        url: mention.data && mention.data.url,
        source: (mention.data && mention.data.author && mention.data.author.name) || 'Someone',
        date: moment(mention.data.published || mention.verified_date).format 'MMM M, YYYY h:mma'
        action: (mention.activity && activityToActionMap[mention.activity.type]) || 'mentioned',
        content: null,
    }

renderMention = (mention) ->
    parts = [];
    parts.push '<span class="post-mention-date">'+mention.date+'</span>' if mention.date
    parts.push '<span class="post-mention-source">'+mention.source+'</span>' # required
    parts.push '<a class="post-mention-action" href="'+mention.url+'">'+mention.action+' this</a>.' # required
    parts.push '<span class="post-mention-content">'+mention.content+'</span>' if mention.content
    parts.join ' '

renderMentions = (mentions) ->
    html = '<ul>'
    for mention in mentions
        niceMention = parseMention mention
        html += '<li>'+(renderMention niceMention)+'</li>'
    html += '</ul>'

insertMentions = (data) ->
    $('.js-mentions').html(renderMentions(data.links)) if data.links.length

fetchMentions = (target) ->
    target = target.replace /^(https?:)?[\/]+|[\/]+$/g, ''
    # List of all acceptable forms that the target may take. Ideally this would
    # be handled by the api, but this ensures that we don't miss mentions that
    # use a trailing slash or different protocol for the target.
    acceptableTargets = [
        target,
        target+'/',
        '//'+target,
        '//'+target+'/',
        'http://'+target,
        'http://'+target+'/',
        'https://'+target,
        'https://'+target+'/',
    ]
    $.getJSON 'https://webmention.io/api/mentions?jsonp=?', {
        target: acceptableTargets,
    }, insertMentions

window.includeMentions = (target) ->
    fetchMentions target