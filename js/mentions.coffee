---
---

class Mention

    ACTION_TEXT_MAP: {
        "default": {
            "like": "liked",
            "mention": "mentioned",
            "reply": "replied to"
        },
        "twitter": {
            "like": "favorited",
        },
    }

    constructor: (@data) ->
        @moment = moment @data.data.published || @data.verified_date

    getDate: ->
        @moment.format 'MMM Do YYYY h:mma'

    getRelativeDate: ->
        @moment.fromNow()

    getSourceUrl: ->
        source = @data.data.url if @data.source.match('brid-gy.appspot.com') && @data.data
        source ||= @data.source

    getSourceName: ->
        sourceUrl = this.getSourceUrl()
        name = 'unrecognized';
        name = 'twitter' if sourceUrl.match 'twitter'
        name = 'facebook' if sourceUrl.match 'facebook'
        name

    getActionType: ->
        (@data.activity && @data.activity.type) || 'mention'

    getActionText: ->
        sourceName = this.getSourceName()
        actionType = this.getActionType()
        (this.ACTION_TEXT_MAP[sourceName] && this.ACTION_TEXT_MAP[sourceName][actionType]) || this.ACTION_TEXT_MAP.default[actionType] || 'mentioned'

    getAuthorName: ->
        (@data.data && @data.data.author && @data.data.author.name) || 'Someone'

    getAuthorSiteUrl: ->
        @data.data && @data.data.author && @data.data.author.url

    getAuthorPhotoUrl: ->
        @data.data && @data.data.author && @data.data.author.photo

    getContent: ->
        (@data.data && @data.data.content) || ''

    renderAction: ->
        sourceUrl = this.getSourceUrl()
        markup = ''
        markup += '<a class="post-mention-action" href="'+sourceUrl+'">' if sourceUrl
        markup += this.getActionText()
        markup += '</a>' if sourceUrl
        markup += ' this'

    renderDate: ->
        date = this.getDate()
        relativeDate = this.getRelativeDate()
        '<div class="post-mention-date" title="'+date+'">'+relativeDate+'</div>'

    renderAuthorName: ->
        '<span class="post-mention-author">'+this.getAuthorName()+'</span>'

    renderAuthorPhoto: ->
        photoUrl = this.getAuthorPhotoUrl();
        siteUrl = this.getAuthorSiteUrl();
        name = this.getAuthorName();
        markup = ''
        markup += '<'+(if siteUrl then 'a href="'+siteUrl+'"' else 'span')+' class="post-mention-author-photo profile-photo profile-photo--small'+(if siteUrl then ' profile-photo--link' else '')+'">'
        markup += '<img class="profile-photo__img" src="'+photoUrl+'" alt="'+name+'" title="'+name+'" />'
        markup += '</'+(if siteUrl then 'a' else 'span')+'>'

    renderContent: ->
        content = this.getContent()
        content && '<div class="post-mention-content">'+content+'</div>'

    render: ->
        renderedContent = this.renderContent();
        parts = [];
        parts.push this.renderAuthorPhoto();
        parts.push '<div class="post-mention-text">'
        parts.push this.renderAuthorName()
        parts.push this.renderAction() + (if renderedContent.length then ':' else '.')
        parts.push renderedContent
        parts.push this.renderDate()
        parts.push '</div>'
        parts = parts.filter (val) ->
            !!val
        parts.join ' '

class MentionHandler

    constructor: (@container, @target) ->
        that = this
        this.fetchMentions (mentions) ->
            that.renderMentions(mentions)

    renderMentions: (mentions) ->
        html = ''
        if mentions.length
            this.sortMentions mentions
            html += '<ul>'
            for mention in mentions
                html += '<li>'+mention.render()+'</li>'
            html += '</ul>'
        $(@container).html(html);

    fetchMentions: (callback) ->
        target = @target.replace /^(https?:)?[\/]+|[\/]+$/g, ''
        # List of all acceptable forms that the target may take. Ideally this would
        # be handled by the api, but this ensures that we don't miss mentions that
        # use a trailing slash or a different protocol for the target.
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
        }, (data) ->
            mentions = (data && data.links) || []
            mentions = mentions.map (mention) ->
                new Mention mention
            callback mentions

    sortMentions: (mentions) ->
        mentions.sort (a, b) ->
            a = a.moment.valueOf()
            b = b.moment.valueOf()
            if a > b then 1 else if a < b then -1 else 0

# Surface this for external use
window.MentionHandler = MentionHandler