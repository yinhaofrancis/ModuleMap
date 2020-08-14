//
//  ModuleMap.swift
//  database
//
//  Created by hao yin on 2020/8/14.
//  Copyright © 2020 Himalaya. All rights reserved.
//

import Foundation
import os

public final class ModuleMap{
    static var lock = DispatchSemaphore(value: 1)
    public static var shard:ModuleMap = {
        return ModuleMap()
    }()
    static var sectionData:Array<Data> = []
    public var section:Array<Data> {
        ModuleMap.lock.wait()
        let section = ModuleMap.sectionData
        ModuleMap.lock.signal()
        return section
    }
    public init() {
        SectionReader()
    }
}

func SectionReader(){
    _dyld_register_func_for_add_image { (header, size) in
        var segSize:UInt = 0
        if(size > 0){
            ModuleMap.lock.wait()
            let p = getsectiondata(unsafeBitCast(header, to: UnsafePointer<mach_header_64>?.self), "__MODULE","__module", &segSize)
            if(size > 0 && p != nil){
                let data = Data(bytes: p!, count: Int(segSize))
                ModuleMap.sectionData.append(data)
            }
            ModuleMap.lock.signal()
        }
        
    }
}
