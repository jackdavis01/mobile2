class FeatureIds {
  // List Page
  static const String listQuickFilters = 'list_quick_filters';
  static const String listFilterButton = 'list_filter_button';
  static const String listFavoriteButton = 'list_favorite_button';
  static const String listFavoriteFilterButton = 'list_favorite_filter_button';

  // Details Page
  static const String detailsZoomIcon = 'details_zoom_icon';
  static const String detailsFavoriteButton = 'details_favorite_button';
  static const String detailsNavigateArrow = 'details_navigate_arrow';
  static const String detailsVerticalPaging = 'details_vertical_paging';

  // Filter Page
  static const String filterSearchBar = 'filter_search_bar';
  static const String filterAdvancedFilters = 'filter_advanced_filters';

  // Navigation Drawer
  static const String navBestDog = 'nav_best_dog';
  static const String navMenuIcon = 'nav_menu_icon';

  // Grouped by page
  static List<String> get listPageFeatures => [
        navMenuIcon,
        listQuickFilters,
        listFilterButton,
        listFavoriteButton,
        listFavoriteFilterButton,
      ];

  static List<String> get detailsPageFeatures => [
        detailsFavoriteButton,
        detailsZoomIcon,
        detailsNavigateArrow,
        detailsVerticalPaging,
      ];

  static List<String> get filterPageFeatures => [
        filterSearchBar,
        filterAdvancedFilters,
      ];

  static List<String> get navigationPageFeatures => [
        navBestDog,
      ];
}
