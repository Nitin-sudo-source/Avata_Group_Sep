//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 06-11-2023
//-------------------------------------------//
public class Ex_CheckRecursive {
    private static boolean run = true;
    
    public static boolean runOnce() {
        if(run) {
            run=false;
            return true;
        } else {
            return run;
        }
    }
}