import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_description.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/products_grid.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/products_list.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/simplified_contact_info.dart';
import 'package:hanouty/app_colors.dart';
import 'package:hanouty/responsive/responsive_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MarketDetailsMobileTabletLayout extends StatelessWidget {
  final String heroTag;
  final String marketName;
  final double rating;
  final String deliveryCost;
  final String deliveryTime;
  final String description;
  final String imageUrl;
  final List<Product> products;

  const MarketDetailsMobileTabletLayout({
    super.key,
    required this.heroTag,
    required this.marketName,
    required this.rating,
    required this.deliveryCost,
    required this.deliveryTime,
    required this.description,
    required this.imageUrl,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final padding = isTablet ? 20.0 : 16.0;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Image with hero animation
          Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: isTablet ? 250 : 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Market name and rating
                Text(
                  marketName,
                  style: TextStyle(
                    fontSize: isTablet ? 24.0 : 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Rating and delivery info
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.delivery_dining, color: AppColors.primary, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      deliveryCost,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      deliveryTime,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // About section
                MarketDescription(
                  description: description,
                  isDesktop: false,
                ),
                
                const SizedBox(height: 24),
                
                // Contact information
                SimplifiedContactInfo(marketName: marketName),
                
                const SizedBox(height: 24),
                
                // Available Products section
                const Text(
                  "Available Products",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Products list for mobile/tablet
                isTablet 
                    ? SizedBox(
                        height: 400,
                        child: ProductsGrid(
                          products: products,
                          crossAxisCount: 3,
                        ),
                      )
                    : SizedBox(
                        height: 220,
                        child: ProductsList(products: products),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}