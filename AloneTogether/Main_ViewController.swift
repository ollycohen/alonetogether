//
//  Main_ViewController.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 11/20/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit

class Main_ViewController: UIViewController {

    private var whirlyVC: WhirlyGlobeViewController?
    var mbTilesFetcher : MaplyMBTileFetcher? = nil
    var imageLoader : MaplyQuadImageLoader? = nil
    
    @IBOutlet weak var centralView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        whirlyVC = WhirlyGlobeViewController()
        centralView.addSubview(whirlyVC!.view)
        whirlyVC!.view.frame = centralView.bounds
        
        let globeVC = whirlyVC as? WhirlyGlobeViewController
        let mapVC = whirlyVC as? MaplyViewController
        
        
          
        // we want a black background for a globe, a white background for a map.
        whirlyVC!.clearColor = (globeVC != nil) ? UIColor.black : UIColor.white

        // and 30 frames per second
        whirlyVC!.frameInterval = 2

        // Set up an MBTiles file and read the header
        mbTilesFetcher = MaplyMBTileFetcher(mbTiles: "geography-class_medres")

        // Sampling parameters define how we break down the globe
        let sampleParams = MaplySamplingParams()
        sampleParams.coordSys = mbTilesFetcher!.coordSys()
        sampleParams.coverPoles = true
        sampleParams.edgeMatching = true
        sampleParams.minZoom = mbTilesFetcher!.minZoom()
        sampleParams.maxZoom = mbTilesFetcher!.maxZoom()
        sampleParams.singleLevel = true

        // The Image Loader does the actual work
        imageLoader = MaplyQuadImageLoader(params: sampleParams,
            tileInfo: mbTilesFetcher!.tileInfo(),
            viewC: whirlyVC!)
        imageLoader!.setTileFetcher(mbTilesFetcher!)
        imageLoader!.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault

        // start up over Madrid, center of the old-world
        if let globeViewC = globeVC {
            globeViewC.height = 0.8
            globeViewC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704, 40.5023),
            time: 1.0)
        }
        else if let mapViewC = mapVC {
            mapViewC.height = 1.0
            mapViewC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704, 40.5023),
            time: 1.0)
        }



        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
