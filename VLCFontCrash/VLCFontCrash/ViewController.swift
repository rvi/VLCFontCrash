//
//  ViewController.swift
//  VLCFontCrash
//
//  Created by Rémy Virin on 24/04/15.
//  Copyright (c) 2015 Rémy Virin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let player = VLCMediaPlayer()

    @IBOutlet weak var vlcView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        player.drawable = vlcView
        let media = VLCMedia(URL: NSURL(string: "https://dl.dropboxusercontent.com/u/16637460/video.mkv"))
        player.setMedia(media)
        
        player.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

