---
---

class Mention
    
    ACTION_TEXT_MAP: {
        "default": {
            "like": "liked",
            "mention": "mentioned",
        },
        "twitter": {
            "like": "favorited",
        },
    }

    constructor: (@data) ->

    getFormattedDate: ->
        moment(@data.data.published || @data.verified_date).format 'MMM Do YYYY, h:mma'

    getSourceUrl: ->
        (@data.data && @data.data.url) || @data.source || ''

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

    getContent: ->
        @data.content || ''

    getRenderString: ->
        sourceUrl = this.getSourceUrl()
        formattedDate = this.getFormattedDate()
        content = this.getContent()
        actionMarkup = ''
        actionMarkup += '<a class="post-mention-action" href="'+sourceUrl+'">' if sourceUrl
        actionMarkup += this.getActionText()+' this'
        actionMarkup += '</a>' if sourceUrl
        actionMarkup += '.'
        parts = [];
        parts.push '<span class="post-mention-date">'+formattedDate+'</span>' if formattedDate
        parts.push '<span class="post-mention-author">'+this.getAuthorName()+'</span>'
        parts.push actionMarkup
        parts.push '<span class="post-mention-content">'+content+'</span>' if content
        parts.join ' '

class MentionHandler

    constructor: (@container, @target) ->
        that = this
        this.fetchMentions (mentions) ->
            that.renderMentions(mentions)

    renderMentions: (mentions) ->
        html = ''
        if mentions.length
            html += '<ul>'
            for mention in mentions
                html += '<li>'+mention.getRenderString()+'</li>'
            html += '</ul>'
        $(@container).html(html);

    fetchMentions: (callback) ->
        target = @target.replace /^(https?:)?[\/]+|[\/]+$/g, ''
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
            # 'https://'+target,
            # 'https://'+target+'/',
        ]
        $.getJSON 'https://webmention.io/api/mentions?jsonp=?', {
            target: acceptableTargets,
        }, (data) ->
            mentions = (data && data.links) || []
            mentions = mentions.map (mention) ->
                new Mention mention
            callback mentions

# Surface this for external use
window.MentionHandler = MentionHandler