final List<Profile> demoProfiles = [
  Profile(
    name: 'Person 1',
    bio: 'description',
    images: [
      'assets/images/image_01.png',
      'assets/images/image_02.jpg',
      'assets/images/image_03.jpg',
      'assets/images/image_04.jpg',
    ],
  ),
  Profile(
    name: 'Person 2',
    bio: 'description',
    images: [
      'assets/images/image_03.jpg',
      'assets/images/image_01.png',
      'assets/images/image_04.jpg',
      'assets/images/image_02.jpg',
    ],
  ),
  Profile(
    name: 'Person 3',
    bio: 'description',
    images: [
      'assets/images/image_02.jpg',
      'assets/images/image_04.jpg',
      'assets/images/image_03.jpg',
      'assets/images/image_01.png',
    ],
  ),
  Profile(
    name: 'Person 4',
    bio: 'description',
    images: [
      'assets/images/image_04.jpg',
      'assets/images/image_01.png',
      'assets/images/image_03.jpg',
      'assets/images/image_02.jpg',
    ],
  ),
];

class Profile{

  final List<String> images;
  final String name;
  final String bio;

  Profile({
    this.images,
    this.name,
    this.bio,
  });

}