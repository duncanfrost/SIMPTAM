function [ outPTAM ] = abfilter(PTAM, World)
   
    dt = 1;
    alpha = 0.4;
    beta = 0.6;
    
    gt = logmap(World.Camera.E);
    v = PTAM.velocity;
    x = PTAM.position;
    
    
    
    
    x = x + dt*v;
    r = gt - x;
    x = x + alpha*r;
    v = v + (beta/dt)*r;
    
    display(norm(r));
    
    
    PTAM.velocity = v; 
    PTAM.position = x;
    
    PTAM.iter = PTAM.iter + 1;
    PTAM.storage{PTAM.iter} = World.Camera.E;
    
    outPTAM = PTAM;
    
    
    save ptam PTAM;
    
    
end

