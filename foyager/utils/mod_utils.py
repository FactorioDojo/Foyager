resources = "/opt/factorio/script-output/resource_data.json"


from sklearn.cluster import MeanShift
import pandas as pd
from collections import defaultdict
import numpy as np
import json

def resource_clustering():
    # Group entities by type
    with open(resources) as f:
        data =  list(json.load(f))
        resource_type = defaultdict(list)
        for entity in data:
            resource_type[entity['resource_type']].append(entity['position'])
        
        # Calculate bounding box for each entity type
        result = {}
        for resource, positions in resource_type.items():
            df = pd.DataFrame(positions)
            
            # Perform Mean Shift clustering
            ms = MeanShift()
            clusters = ms.fit_predict(df)
            
            # Calculate bounding box for each cluster
            result[resource] = []
            for cluster_id in np.unique(clusters):
                cluster_positions = df[clusters == cluster_id]
                min_x = cluster_positions['x'].min()
                max_x = cluster_positions['x'].max()
                min_y = cluster_positions['y'].min()
                max_y = cluster_positions['y'].max()
                
                result[resource].append({
                    'count': len(cluster_positions),
                    'bounding_box': {
                        'min': {'x': min_x, 'y': min_y},
                        'max': {'x': max_x, 'y': max_y},
                    }
                })
        
        return result

