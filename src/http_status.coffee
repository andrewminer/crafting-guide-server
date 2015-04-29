###
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

########################################################################################################################

module.exports =
    continue:                       100
    switchingProtocols:             101

    ok:                             200
    created:                        201
    accepted:                       202
    nonAuthoratitive:               203
    noContent:                      204
    resetContent:                   205
    partialContent:                 206

    multipleChoices:                300
    movedPermanently:               301
    found:                          302
    seeOther:                       303
    notModified:                    304
    useProxy:                       305
    # unused:                       306
    temporaryRedirect:              307

    badRequest:                     400
    unauthorized:                   401
    paymentRequired:                402
    forbidden:                      403
    notFound:                       404
    methodNotAllowed:               405
    notAcceptable:                  406
    proxyAuthenticationRequired:    407
    requestTimeout:                 408
    conflict:                       409
    gone:                           410
    lengthRequired:                 411
    preconditionFailed:             412
    requestEntityTooLarge:          413
    requestUriTooLong:              414
    unsupportedMediaType:           415
    requestedRangeNotSatisfiable:   416
    expectationFailed:              417

    internalServerError:            500
    notImplemented:                 501
    badGateway:                     502
    serviceUnavailable:             503
    gatewayTimeout:                 504
    httpVersionNotSupported:        505

for name, code of module.exports
    module.exports[name] = code = new Number code
    code.throw = ((c)-> return (message=null, data={}, error=e)->
        message ?= name
        e = new Error message
        e.statusCode = c
        e.data = data
        e.originalError = error
        throw e
    )(code)
