//
//  RealmDB.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 3..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Realm/Realm.h>

@interface RealmDB : RLMObject
// Add properties here to define the model

@end

// This protocol enables typed collections. i.e.:
// RLMArray<RealmDB *><RealmDB>
RLM_ARRAY_TYPE(RealmDB)
