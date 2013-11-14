###*@license kiana 0.1
    Copyright (c) 2013 Zaur Nasibov, http://znasibov.info
    Distributed under the MIT license
###

window['kidomi'] =
kidomi = (data) ->
    # Filter existing nodes or objects which can be
    # directly converted to a node.
    node = extractNode(data)
    if node?
        return node

    if not isArray(data)
        throw "Expected an array, got: #{data}"
    if data.length == 0
        throw 'Expected a non-empty array'

    tagToken = data[0]
    tagData = parseTagToken(tagToken)
    elem = makeElementFromTagData(tagData)

    if data.length == 2
        # Cases:
        # ['elem', 'text']
        # ['elem', ['sub-elem']]
        # ['elem', {'attr1' : value}]
        token = data[1]
        if not isObject(token)
            childElem = kidomi(token)
        else
            addAttributes(elem, token)
            childElem = kidomi('')
        elem.appendChild(childElem)
    else if data.length >= 3
        # Cases:
        # ['elem', ['sub-elem1', ...], ..., text]
        # ['elem', ['sub-elem1'], ...]
        # ['elem', {'attr1' : value}, ['sub-elem1', ...], ..., text]
        # ['elem', {'attr1' : value}, ['sub-elem1', ...], ...]
        subElemStartIndex = 1
        if isObject(data[1])
            addAttributes(elem, data[1])
            subElemStartIndex = 2
        for subArr in data[subElemStartIndex..]
            childElem = kidomi(subArr)
            elem.appendChild(childElem)
    elem


## Returns a node if obj is an existing node or can be converted to a node.
kidomi.extractNode =
extractNode = (obj) ->
    if isString(obj)
        return document.createTextNode(obj)
    if obj instanceof Node
        return obj
    null


kidomi.makeElementFromTagData =
makeElementFromTagData = (tagData) ->
    if tagData.name == ''
        throw 'Empty tag name in #{data}'
    elem = document.createElement(tagData.name)
    if tagData.id != ''
        elem.id = tagData.id
    if tagData.classes.length > 0
        elem.className = tagData.classes.join(' ')
    elem


kidomi.addAttributes =
addAttributes = (elem, data) ->
    if data.style?
        styleString = if isString(data.style)
            data.style
        else
            styleItems = []
            for name, val of data.style
                styleItems.push("#{name}: #{val};")
            styleItems.join(' ')
        elem.style.cssText = styleString

    if data.class?
        classString = if isArray(data.class)
            data.class.join(' ')
        else
            data.class
        if elem.className ?= ''
            elem.className += ' '
        elem.className += classString

    for name, val of data
        if name not in ['class', 'style']
            elem.setAttribute(name, val)


kidomi.parseTagToken =
parseTagToken = (tagToken) ->
    classSplitData = tagToken.split('.')
    tagNameAndId = classSplitData.shift()
    tagNameAndIdSplit = tagNameAndId.split('#')
    tagName = tagNameAndIdSplit[0]
    tagId = tagNameAndIdSplit[1] ? ''

    {
        name: tagName
        id: tagId
        classes: classSplitData
    }


kidomi.isArray =
isArray = (arr) ->
    arr instanceof Array

kidomi.isString =
isString = (s) ->
    typeof(s) == 'string' or s instanceof(String);

kidomi.isObject =
isObject = (obj) ->
    obj?.constructor == Object