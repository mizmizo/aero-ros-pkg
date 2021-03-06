FROM osrf/ros:indigo-desktop-full
SHELL ["bash", "-c"]

# prepare catkin and all euslisp packages
RUN apt-get -q -qq update && apt-get -q -qq install -y \
    ros-indigo-catkin \
    ros-indigo-ros \
    ros-indigo-desktop-full \
    ros-indigo-pr2-controllers-msgs \
    ros-indigo-move-base-msgs \
    ros-indigo-moveit-full \
    bc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/
RUN easy_install pip \
    && pip install -U pip setuptools \
    && pip install catkin_pkg catkin_tools

# create catkin workspace
RUN mkdir -p /catkin_ws/src/aero-ros-pkg-prerelease
WORKDIR /catkin_ws
RUN wstool init /catkin_ws/src
COPY . /catkin_ws/src/aero-ros-pkg-prerelease/

# catkin build
WORKDIR /catkin_ws
RUN source /opt/ros/indigo/setup.bash \
    && catkin config --init
RUN source /opt/ros/indigo/setup.bash \
    && catkin build aero_description
WORKDIR /catkin_ws/src/aero-ros-pkg-prerelease/aero_description
RUN source /catkin_ws/devel/setup.bash \
    && ./setup.sh typeF
WORKDIR /catkin_ws
RUN source /catkin_ws/devel/setup.bash \
    && catkin build aero_std
RUN source /catkin_ws/devel/setup.bash \
    && catkin run_tests aero_std
RUN source /catkin_ws/devel/setup.bash \
    && catkin build aero_samples
