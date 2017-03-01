/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

extern NSString* const SINVerificationErrorDomain;

enum {
  SINVerificationErrorInvalidInput = 1,  // Invalid input, client-side (e.g. nil input)
  SINVerificationErrorIncorrectCode,
  SINVerificationErrorServiceError,  // Sinch backend service error
};
