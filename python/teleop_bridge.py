#!/usr/bin/env python3

from cartesian_interface.pyci_all import *
import rospy
from geometry_msgs.msg import PoseStamped
from scipy.spatial.transform import Rotation as R
import numpy as np

ci = pyci.CartesianInterfaceRos()
initial_ref = PoseStamped()
controlled_frame = str()
z_offset = 0.08

def callback(data: PoseStamped):
    global controlled_frame
    r = R.from_quat(
        [
            data.pose.orientation.x,
            data.pose.orientation.y,
            data.pose.orientation.z,
            data.pose.orientation.w,
        ]
    )
    data_m = Affine3()
    data_m.translation = np.array(
        [data.pose.position.x, data.pose.position.y, data.pose.position.z - z_offset]
    )
    data_m.linear = r.as_matrix()

    pose_ref = Affine3()
    pose_ref.translation = data_m.translation
    pose_ref.linear = data_m.linear

    ci.setPoseReference(controlled_frame, pose_ref)


if __name__ == "__main__":
    rospy.init_node("teleop_bridge", anonymous=False)

    if rospy.has_param("~controlled_frame"):
        controlled_frame = rospy.get_param("~controlled_frame")
    else:
        rospy.logerr("controlled_frame private param is mandatory! Exiting.")
        exit()

    rospy.loginfo(f"controlled_frame: {controlled_frame}")

    rospy.Subscriber("teleop_pose", PoseStamped, callback)

    rospy.spin()
